import datetime
from django.db import models
import datetime
from django.db import models
from django import forms
from django.forms import ModelForm
from django.contrib.gis.db import models


class Sensors():
    latitud = models.DecimalField(max_digits=4, decimal_places=2)
    longitud = models.DecimalField(max_digits=4, decimal_places=2)
    address = models.CharField(max_length=200)
    town = models.CharField(max_length=200,unique=True, db_index=True, primary_key=True)
    country = models.CharField(max_length=200)
    region = models.CharField(max_length=200)
    def __unicode__(self):              # __unicode__ on Python 2
        return self.town


class Observaciones():
    tiempo = models.CharField(max_length=20)
    medida = models.DecimalField(max_digits=6, decimal_places=6)
    descripcion = models.CharField(max_length=200) 
    def __unicode__(self):              # __unicode__ on Python 2
        return self.descripcion_text

class DatosIndex():

    puntos = models.DecimalField(max_digits=4, decimal_places=2)
    longitud = models.DecimalField(max_digits=4, decimal_places=2)
    address = models.CharField(max_length=200)
    town = models.CharField(max_length=200)
    country = models.CharField(max_length=200)
    region = models.CharField(max_length=200)
    def __unicode__(self):              # __unicode__ on Python 2
        return self.town_text



class BusquedaObservaciones(forms.Form):
    #sensorId = forms.CharField(label='Sensor id', max_length=5)
    fecha = forms.DateField(required=True)
    fechaHasta = forms.DateField(required=True)
    # tipoSensor = forms.CharField(label='Tipo de Sensor', max_length=100)
   

class Posicion(forms.Form):
    latitud = forms.CharField(max_length=30, required="false")
    longitud = forms.CharField(max_length=30, required="false")
    direccion = forms.CharField(max_length=200, required="false")
    idEstacion = forms.CharField(max_length=30, required="false")
   

class Agente(forms.Form):
    agente = forms.CharField(max_length=30)  

class Catalogo():
    codigo = models.CharField(max_length=10)
    descripcion = models.CharField(max_length=100)
    referencia = forms.CharField(max_length=10)

class Info():
    descripcion = models.CharField(max_length=10000000000)
    detalles = forms.CharField(max_length=20)
    error =  forms.CharField(max_length=50)

class RangoSimple():
    desde = models.DecimalField(max_digits=3, decimal_places=2)
    hasta =  models.DecimalField(max_digits=3, decimal_places=2)
    clasificacion = models.CharField(max_length=20)
    

class Notificaciones():
    fecha= models.CharField(max_length=10)
    mensaje= models.CharField(max_length=10000)

class ObservacionesRecientes():
    descripcion = models.CharField(max_length=100)
    fecha = models.CharField(max_length=10)
    hora = models.CharField(max_length=8)
    valor = models.CharField(max_length=30)
    unidad = models.CharField(max_length=10)
    definicion= models.CharField(max_length=10000)
    abreviatura = models.CharField(max_length=20)
    
class Rango(models.Model):
    idsensor = models.IntegerField(unique=True, db_index=True, primary_key=True)
    desde = models.DecimalField(max_digits=3, decimal_places=2)
    hasta =  models.DecimalField(max_digits=3, decimal_places=2)
    clasificacion = models.CharField(max_length=20)
    def __str__(self):
            return '%s %s' % (self.desde, self.hasta)

class Estacion(models.Model):
    idestacion = models.IntegerField(unique=True, db_index=True, primary_key=True)
    idproyecto = models.IntegerField()
    clasificacion = models.CharField(max_length=10)
    direccion = models.CharField(max_length=200)


class Observacion(models.Model):
    idestacion =  models.IntegerField()
    idsensor = models.IntegerField(unique=True, db_index=True, primary_key=True)
    abreviatura = models.CharField(max_length=20)
    descripcion = models.CharField(max_length=100)
    unidad = models.CharField(max_length=10)
    valor = models.DecimalField(max_digits=4, decimal_places=3)
    fecha = models.DateTimeField()
    clasificacion = models.CharField(max_length=10)
    idproyecto = models.IntegerField()

class Sensor(models.Model):
    idsensor = models.IntegerField(unique=True, db_index=True, primary_key=True)
    abreviatura = models.CharField(max_length=20)
    descripcion = models.CharField(max_length=100)
    unidad = models.CharField(max_length=10)
    definicion= models.CharField(max_length=10000)
    
class Notificacion(models.Model):
    idsensor = models.IntegerField(unique=True, db_index=True, primary_key=True)
    tipo = models.CharField(max_length=20)
    limite = models.DecimalField(max_digits=4, decimal_places=3)
    plantilla = models.CharField(max_length=10000)

class Mensaje(models.Model):
    idsensor = models.IntegerField(unique=True, db_index=True, primary_key=True)
    fecha = models.DateTimeField() 
    valor = models.DecimalField(max_digits=4, decimal_places=3)
    mensaje = models.CharField(max_length=10000)

class Mails(models.Model):
    tipo = models.CharField(max_length=30)
    direccion = models.CharField(max_length=100)
