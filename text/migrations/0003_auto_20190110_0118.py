# Generated by Django 2.1.2 on 2019-01-10 01:18

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('text', '0002_auto_20181108_0715'),
    ]

    operations = [
        migrations.CreateModel(
            name='TextGroupWord',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('order', models.IntegerField(default=0)),
            ],
        ),
        migrations.CreateModel(
            name='TextWordGroup',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
            ],
        ),
        migrations.CreateModel(
            name='TextWordGroupTranslation',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('correct_for_context', models.BooleanField(default=False)),
                ('phrase', models.TextField()),
                ('group', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='translations', to='text.TextWordGroup')),
            ],
        ),
        migrations.AddField(
            model_name='textgroupword',
            name='group',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='components', to='text.TextWordGroup'),
        ),
        migrations.AddField(
            model_name='textgroupword',
            name='word',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='group_word', to='text.TextWord'),
        ),
        migrations.AlterUniqueTogether(
            name='textgroupword',
            unique_together={('group', 'word', 'order')},
        ),
    ]
