import json

from typing import TypeVar, Dict, Union

from django import forms
from django.contrib.auth import login, logout
from django.http import HttpResponse, HttpRequest, HttpResponseForbidden
from django.urls import reverse

from django.views.generic import TemplateView, View

from text.models import TextDifficulty
from user.forms import StudentSignUpForm, StudentLoginForm, StudentForm
from user.student.models import Student
from user.views.api import APIView
from user.views.mixin import ProfileView
from django.contrib.auth.mixins import LoginRequiredMixin
from mixins.view import ElmLoadJsStudentBaseView, NoAuthElmLoadJsView

from django.template import loader


Form = TypeVar('Form', bound=forms.Form)


class ElmLoadJsStudentView(ElmLoadJsStudentBaseView):
    def get_context_data(self, **kwargs) -> Dict:
        context = super(ElmLoadJsStudentView, self).get_context_data(**kwargs)

        profile = None

        try:
            profile = self.request.user.student
        except Student.DoesNotExist:
            pass

        performance_report_html = loader.render_to_string('student_performance_report.html', {
            'performance_report': profile.performance.to_dict()
        })

        performance_report_pdf_link = reverse('student-performance-pdf-link', kwargs={'pk': profile.pk})

        context['elm']['student_profile'] = {'quote': False, 'safe': True, 'value': profile.to_dict()}

        context['elm']['performance_report'] = {'quote': False, 'safe': True, 'value': {
            'html': performance_report_html,
            'pdf_link': performance_report_pdf_link,
        }}

        context['elm']['flashcards'] = {'quote': False, 'safe': True, 'value': [
            card.phrase.phrase for card in profile.flashcards.all()
        ] if profile.flashcards else None}

        try:
            welcome = self.request.session['welcome']['student_profile']
        except KeyError:
            welcome = False

        try:
            if welcome:
                student_session = self.request.session['welcome']

                del student_session['student_profile']

                self.request.session['welcome'] = student_session
        except KeyError:
            pass

        context['elm']['welcome'] = {
            'quote': False,
            'safe': True,
            'value': json.dumps(welcome)
        }

        return context


class ElmLoadStudentSignUpView(NoAuthElmLoadJsView):
    def get_context_data(self, **kwargs) -> Dict:
        context = super(ElmLoadStudentSignUpView, self).get_context_data(**kwargs)

        context['elm']['difficulties'] = {'quote': False, 'safe': True,
                                          'value':
                                              json.dumps([(text_difficulty.slug, text_difficulty.name)
                                                          for text_difficulty in TextDifficulty.objects.all()])}

        def url_elm_value(url):
            return {'quote': True, 'safe': True, 'value': url}

        context['elm'].update({
            'user_type': {'quote': True, 'safe': True, 'value': 'student'},
            'student_signup_uri': url_elm_value(reverse('api-student-signup')),
            'signup_page_url': url_elm_value(reverse('student-signup')),

            'login_uri': url_elm_value(reverse('api-student-login')),
            'login_page_url': url_elm_value(reverse('instructor-login')),

            'reset_pass_endpoint': url_elm_value(reverse('api-password-reset')),
            'forgot_pass_endpoint': url_elm_value(reverse('api-password-reset-confirm')),
            'forgot_password_url': url_elm_value(reverse('password-reset')),
        })

        return context


class ElmLoadJsStudentLoginView(NoAuthElmLoadJsView):
    def get_context_data(self, **kwargs) -> Dict:
        context = super(ElmLoadJsStudentLoginView, self).get_context_data(**kwargs)

        def url_elm_value(url):
            return {'quote': True, 'safe': True, 'value': url}

        context['elm'].update({
            'user_type': {'quote': True, 'safe': True, 'value': 'student'},
            'signup_uri': url_elm_value(reverse('api-student-signup')),
            'signup_page_url': url_elm_value(reverse('student-signup')),

            'login_uri': url_elm_value(reverse('api-student-login')),
            'login_page_url': url_elm_value(reverse('instructor-login')),

            'reset_pass_endpoint': url_elm_value(reverse('api-password-reset')),
            'forgot_pass_endpoint': url_elm_value(reverse('api-password-reset-confirm')),
            'forgot_password_url': url_elm_value(reverse('password-reset')),
        })

        return context


class StudentView(ProfileView):
    profile_model = Student
    login_url = Student.login_url


class StudentAPIView(LoginRequiredMixin, APIView):
    # returns permission denied HTTP message rather than redirect to login
    raise_exception = True

    def form(self, request: HttpRequest, params: dict, **kwargs) -> forms.ModelForm:
        return StudentForm(params, **kwargs)

    def get(self, request: HttpRequest, *args, **kwargs) -> HttpResponse:
        if not Student.objects.filter(pk=kwargs['pk']).count():
            return HttpResponse(status=400)

        student = Student.objects.get(pk=kwargs['pk'])

        if student.user != self.request.user:
            return HttpResponseForbidden()

        student_dict = student.to_dict()
        student_flashcards = student_dict.pop('flashcards')
        student_performance_report = student_dict.pop('performance_report')

        # TODO(andrew.silvernail): frontend on the student profile page is expecting text word dicts
        # refactor later

        return HttpResponse(json.dumps({
            'profile': student_dict,
            'performance_report': student_performance_report,
        }))

    def post_success(self, request: HttpRequest, form: Form) -> HttpResponse:
        raise NotImplementedError

    def put_error(self, errors: dict) -> HttpResponse:
        return HttpResponse(json.dumps(errors), status=400)

    def put_success(self, request: HttpRequest, student_form: Union[Form, forms.ModelForm]) -> HttpResponse:
        student = student_form.save()

        return HttpResponse(json.dumps(student.to_dict()))

    def put(self, request, *args, **kwargs) -> HttpResponse:
        errors = params = {}

        if not Student.objects.filter(pk=kwargs['pk']).count():
            return HttpResponse(status=400)

        student = Student.objects.get(pk=kwargs['pk'])

        if student.user != self.request.user:
            return HttpResponseForbidden()

        try:
            params = json.loads(request.body.decode('utf8'))
        except json.JSONDecodeError as e:
            return self.put_json_error(e)

        if 'difficulty_preference' in params:
            try:
                params['difficulty_preference'] = TextDifficulty.objects.get(slug=params['difficulty_preference']).pk
            except TextDifficulty.DoesNotExist:
                pass

        form = self.form(request, params, instance=student)

        if not form.is_valid():
            errors = self.format_form_errors(form)

        if errors:
            return self.put_error(errors)
        else:
            return self.put_success(request, form)


class StudentSignupAPIView(APIView):
    def form(self, request: HttpRequest, params: dict) -> forms.ModelForm:
        return StudentSignUpForm(params)

    def post_success(self, request: HttpRequest, student_signup_form: Form) -> HttpResponse:
        student = student_signup_form.save()

        request.session['welcome'] = {
            'student_profile': True,
            'student_search': True
        }

        return HttpResponse(json.dumps({'id': student.pk, 'redirect': reverse('student-login')}))


class StudentLogoutAPIView(LoginRequiredMixin, View):
    def post(self, request: HttpRequest, *args, **kwargs) -> HttpResponse:
        logout(request)

        return HttpResponse(json.dumps({'redirect': reverse('student-login')}))


class StudentLoginAPIView(APIView):
    def form(self, request: HttpRequest, params: dict) -> Form:
        return StudentLoginForm(request, params)

    def post_success(self, request: HttpRequest, student_login_form: Form) -> HttpResponse:
        reader_user = student_login_form.get_user()

        if hasattr(reader_user, 'instructor'):
            return self.post_error({'all': 'Something went wrong.  Please try a different username and password.'})

        login(self.request, reader_user)

        student = reader_user.student

        return HttpResponse(json.dumps({'id': student.pk, 'redirect': reverse('student-profile')}))


class StudentSignUpView(TemplateView):
    template_name = 'student/signup.html'

    def get_context_data(self, **kwargs) -> dict:
        context = super(StudentSignUpView, self).get_context_data(**kwargs)

        context['title'] = 'Student Signup'

        context['difficulties'] = json.dumps([(text_difficulty.slug, text_difficulty.name)
                                              for text_difficulty in TextDifficulty.objects.all()])

        return context


class StudentLoginView(TemplateView):
    template_name = 'student/login.html'

    def get_context_data(self, **kwargs):
        context = super(StudentLoginView, self).get_context_data(**kwargs)

        context['title'] = 'Student Login'

        return context


class StudentProfileView(StudentView, TemplateView):
    template_name = 'student/profile.html'

    def get_context_data(self, **kwargs):
        context = super(StudentProfileView, self).get_context_data(**kwargs)

        context['title'] = 'Student Profile'

        return context


class StudentFlashcardView(StudentView, TemplateView):
    template_name = 'student/flashcards.html'

    def get_context_data(self, **kwargs):
        context = super(StudentFlashcardView, self).get_context_data(**kwargs)

        context['title'] = 'Student Flashcards'

        return context
