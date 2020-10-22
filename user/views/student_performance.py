from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
import pdfkit
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.files.base import ContentFile
from django.http import HttpResponse, HttpRequest, HttpResponseForbidden
from django.template import loader
from django.utils import timezone as dt
from django.views.generic import View

from user.student.models import Student

from auth.normal_auth import jwt_validation

class StudentPerformancePDFView(View):

    def get(self, request: HttpRequest, *args, **kwargs) -> HttpResponse:
        if not Student.objects.filter(pk=kwargs['pk']).exists():
            return HttpResponse(status=400)

        student = Student.objects.get(pk=kwargs['pk'])

        # do the jwt auth here
        verified_user = jwt_validation(self.request.scope)

        # confirm the user_id from the URL is the same as the JWT's
        if verified_user == None or student.pk != verified_user.pk:
            return HttpResponse(status=403)

        today = dt.now()

        pdf_filename = f'my_ereader_performance_{today.day}_{today.month}_{today.year}.pdf'

        performance_report_html = loader.render_to_string('student_performance_report.html',
                                                          {'performance_report': student.performance.to_dict()})

        pdf_data = pdfkit.from_string(performance_report_html, False)

        pdf = ContentFile(pdf_data)

        resp = HttpResponse(pdf, 'application/pdf')

        resp['Content-Length'] = pdf.size
        resp['Content-Disposition'] = f'attachment; filename="{pdf_filename}"'

        return resp
