from django.db import models
from text.models import TextDifficulty
from user.models import ReaderUser


class Student(models.Model):
    user = models.OneToOneField(ReaderUser, on_delete=models.CASCADE)
    difficulty_preference = models.ForeignKey(TextDifficulty, null=True, on_delete=models.SET_NULL,
                                              related_name='students')

    def to_dict(self):
        difficulties = [(text_difficulty.slug, text_difficulty.name)
                        for text_difficulty in TextDifficulty.objects.all()]

        # difficulty_preference can be null
        difficulties.append(('', ''))

        return {
            'id': self.pk,
            'username': self.user.username,
            'difficulty_preference': [self.difficulty_preference.slug, self.difficulty_preference.name]
            if self.difficulty_preference else None,
            'difficulties': difficulties,
            'text_reading': [text_reading.to_dict() for text_reading in self.text_readings.all()]
        }

    def __str__(self):
        return self.user.username
