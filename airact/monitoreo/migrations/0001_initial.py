# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2016-06-09 21:36
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Estacion',
            fields=[
                ('idestacion', models.IntegerField(db_index=True, primary_key=True, serialize=False, unique=True)),
                ('idproyecto', models.IntegerField()),
                ('clasificacion', models.CharField(max_length=10)),
                ('direccion', models.CharField(max_length=200)),
            ],
        ),
        migrations.CreateModel(
            name='Mails',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('tipo', models.CharField(max_length=30)),
                ('direccion', models.CharField(max_length=100)),
            ],
        ),
        migrations.CreateModel(
            name='Mensaje',
            fields=[
                ('idsensor', models.IntegerField(db_index=True, primary_key=True, serialize=False, unique=True)),
                ('fecha', models.DateTimeField()),
                ('valor', models.DecimalField(decimal_places=3, max_digits=4)),
                ('mensaje', models.CharField(max_length=10000)),
            ],
        ),
        migrations.CreateModel(
            name='Notificacion',
            fields=[
                ('idsensor', models.IntegerField(db_index=True, primary_key=True, serialize=False, unique=True)),
                ('tipo', models.CharField(max_length=20)),
                ('limite', models.DecimalField(decimal_places=3, max_digits=4)),
                ('plantilla', models.CharField(max_length=10000)),
            ],
        ),
        migrations.CreateModel(
            name='Observacion',
            fields=[
                ('idestacion', models.IntegerField()),
                ('idsensor', models.IntegerField(db_index=True, primary_key=True, serialize=False, unique=True)),
                ('abreviatura', models.CharField(max_length=20)),
                ('descripcion', models.CharField(max_length=100)),
                ('unidad', models.CharField(max_length=10)),
                ('valor', models.DecimalField(decimal_places=3, max_digits=4)),
                ('fecha', models.DateTimeField()),
                ('clasificacion', models.CharField(max_length=10)),
                ('idproyecto', models.IntegerField()),
            ],
        ),
        migrations.CreateModel(
            name='Rango',
            fields=[
                ('idsensor', models.IntegerField(db_index=True, primary_key=True, serialize=False, unique=True)),
                ('desde', models.DecimalField(decimal_places=2, max_digits=3)),
                ('hasta', models.DecimalField(decimal_places=2, max_digits=3)),
                ('clasificacion', models.CharField(max_length=20)),
            ],
        ),
        migrations.CreateModel(
            name='Sensor',
            fields=[
                ('idsensor', models.IntegerField(db_index=True, primary_key=True, serialize=False, unique=True)),
                ('abreviatura', models.CharField(max_length=20)),
                ('descripcion', models.CharField(max_length=100)),
                ('unidad', models.CharField(max_length=10)),
                ('definicion', models.CharField(max_length=10000)),
            ],
        ),
    ]
