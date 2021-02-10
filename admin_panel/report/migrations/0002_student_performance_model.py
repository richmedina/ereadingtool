# Generated by Django 2.1.2 on 2018-11-08 07:15

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('report', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='StudentPerformance',
            fields=[
                ('id', models.BigIntegerField(primary_key=True, serialize=False)),
                ('start_dt', models.DateTimeField()),
                ('end_dt', models.DateTimeField()),
                ('text_difficulty_slug', models.SlugField()),
                ('answered_correctly', models.IntegerField()),
                ('attempted_questions', models.IntegerField()),
            ],
            options={
                'db_table': 'report_student_performance',
                'managed': False,
            },
        ),
    ]
