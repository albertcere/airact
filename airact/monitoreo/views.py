import time
from datetime import date
from datetime import timedelta
from django.shortcuts import render, redirect
from django.http import HttpResponse, HttpResponseRedirect
from django.core.urlresolvers import reverse
from django.utils import translation
from rdflib import Graph
import dateutil.parser
from django.conf import settings
import requests
from dateutil import tz
import dateutil.parser
from datetime import datetime
from unicodedata import normalize
from django.utils.translation import ugettext as _

import MySQLdb as mdb
import sys
from django.db import connection
from monitoreo.models import Estacion, Catalogo, Agente, Observaciones, ObservacionesRecientes, BusquedaObservaciones

#Views of monitoreo

# Redirects the user
# if it is a phone
#     rediredt to current station
# else rediredt to map

def index(request):
    if(request.is_phone):
        return HttpResponseRedirect(reverse('monitoreo:station', args=('current',)))
    return redirect('monitoreo:map')

# Functions

def determinaIcono(estaciones, id):
    estacion = Estacion()
    clasi = "i9"
    estacion = filter(lambda x: int(x.idestacion)  == int(id) and x.clasificacion!="", estaciones)
    for est in estacion:
             clasi =  est.clasificacion
    return clasi

def conexion():
    return mdb.connect(settings.APP_DATABASES['default']['HOST'],
        settings.APP_DATABASES['default']['USER'],
        settings.APP_DATABASES['default']['PASSWORD'],
        settings.APP_DATABASES['default']['NAME'],
        charset='utf8')

def map(request):
    cat=[]
    separadorSensores = ":::"
    separadorPropiedades = "@"
    puntosCat = ""
    puntosMad = ""
    agente=""
    id="0"

    currentlang = translation.get_language()

    if request.method == 'POST':
        form = Agente(request.POST)
        if form.is_valid():
            agente = (form.cleaned_data['agente'])

    conex = conexion()
    cursor = conex.cursor()
    
    if agente=="":
        sql = ("select  idproyecto,idestacion,direccion,clasificacion,"
            " X(coordenadas) as x, Y(coordenadas) as y"
            " from monitoreo.monitoreo_estacion"
            " where idproyecto =  " + settings.ID_PROJECT + " ;")
    else:
        sql = ("select  E.idproyecto,E.idestacion,E.direccion,"
            "IF( O.clasificacion='','i8' ,  O.clasificacion) clasificacion,"
            " X(coordenadas) as x, Y(coordenadas) as y"
            " from monitoreo.monitoreo_estacion as E"
            " INNER JOIN monitoreo.monitoreo_observacion as O ON E.idestacion = O.idestacion"
            "  where idproyecto =  " + settings.ID_PROJECT + "   and O.idsensor= "+agente+" ;")
    cursor.execute(" SET  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;")    
    cursor.execute(sql)
    for row in cursor.fetchall():
        id = row[1]
        direccion = row[2]
        
        
        latitud=row[4]
        longitud=row[5]

        icono = row[3]
        if (icono==""):
            icono="i9"

        #======================= Stations string =============================
        
        if(icono != "i8" and icono != "i9"):
            if(float(longitud) > 0): 
                puntosCat = (puntosCat +
                    str(direccion) + separadorPropiedades +
                    str(latitud) + separadorPropiedades +
                    str(longitud) + separadorPropiedades +
                    icono + separadorPropiedades  +
                    ""  + separadorPropiedades +
                    str(id) + separadorSensores)
            else: 
                puntosMad = (puntosMad +
                    str(direccion) + separadorPropiedades +
                    str(latitud) + separadorPropiedades +
                    str(longitud) + separadorPropiedades +
                    icono + separadorPropiedades  +
                    ""  + separadorPropiedades +
                    str(id) + separadorSensores)
    
    cursor.execute("select idsensor, descripcion_"+currentlang+", abreviatura"
        "  from monitoreo.monitoreo_sensor"
        " where idsensor < 10 AND idsensor > 2 AND idsensor != 7"
        " order by descripcion ;" )

    for row in cursor.fetchall():
        catalogo = Catalogo()
        catalogo.codigo = row[0]
        catalogo.descripcion = row[1][:40]
        catalogo.referencia = row[2]
        cat.append(catalogo)
        

    conex.close()

    if(agente!=""):
        agente = int(agente)
    phone = 'No'
    if(request.is_phone):
        phone = 'Yes'

    context = {'puntosmapaCat': puntosCat,
        'puntosmapaMad': puntosMad,
        'cat': cat,'agent': agente,
        'phone': phone,
        'nbar': 'map'}

    return render(request, 'monitoreo/map.html', context)

# List of stations

def list_stations(request):

    estaciones = []
    ordenar = 1

    if request.method == 'POST':
        ordenar = int(request.POST.get("ordenar", "1"))

    conex = conexion()
    cursor = conex.cursor()
    sql = ("select  idproyecto,idestacion,direccion,clasificacion,"
        " X(coordenadas) as x, Y(coordenadas) as y"
        " from monitoreo.monitoreo_estacion"
        " where idproyecto =  " + settings.ID_PROJECT + " ")
    if(ordenar == 1):
        sql = sql + "order by direccion;"
    elif(ordenar == 2):
        sql = sql + "order by clasificacion desc;"
    cursor.execute(sql)
    for row in cursor.fetchall():
        idestacion = row[1]
        direccion = row[2]
        
        
        latitud=row[4]
        longitud=row[5]

        icono = row[3]
        if (icono==""):
            icono="i9"

        if(icono != "i8" and icono != "i9"):
            estaciones.append({'id': idestacion,
                'direccion': direccion,
                'latitud': latitud,
                'longitud': longitud,
                'icono': icono})


    context = {'estaciones': estaciones,'ordenar': ordenar,'nbar': 'list'}
    return render(request, 'monitoreo/list.html', context)

# Info about a station

def station(request, station):
    currentlang = translation.get_language()

    # Get closest station
    if(station == 'current'):

        bandera = '2'
        context = {'bandera': bandera, 'station': 'current', 'nbar': 'station'}

        if request.method == 'POST':
            bandera = '0'

            lat = request.POST.get("lat", "")
            lng = request.POST.get("lng", "")

            stationid = estacionCercana(lat, lng)
            if(stationid != ""): #Got the closest station



                observaciones = []
                ids = []
                obsRecientes = []
                bandera = "1"
                sql = ""
                direccion = ""
                latitud = ""
                longitud = ""
                clasificacion = ""
                
                conex = conexion()
                cursor = conex.cursor()
               

                cursor.execute(" SET  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;")
                sql = (sql + " select descripcion_"+currentlang+",fecha,valor,unidad,O.clasificacion, E.direccion,"
                    " X(coordenadas) as x, Y(coordenadas) as y, E.clasificacion, S.idsensor"
                    " from monitoreo.monitoreo_observacion as O INNER JOIN")
                sql = sql + " monitoreo.monitoreo_sensor as S ON O.idsensor = S.idsensor INNER JOIN"
                sql = sql + " monitoreo.monitoreo_estacion as E ON O.idestacion = E.idestacion"
                sql = sql + " WHERE E.idproyecto = "+ settings.ID_PROJECT + " AND E.idestacion=" + str(stationid) + ";"
                cursor.execute(sql)

                for row in cursor.fetchall():
                    ids.append(row[9])
                    direccion = row[5]
                    latitud = row[6]
                    longitud = row[7]
                    clasificacion = row[8]
                    obsRec = ObservacionesRecientes()
                    obsRec.descripcion=row[0]
                    obsRec.fecha= row[1].strftime('%d/%m/%Y')
                    obsRec.hora=row[1].strftime('%d/%m/%Y %H:%M:%S')
                    
                    if (float(row[2])==float(-9999)):
                        obsRec.valor=""
                        obsRec.unidad=""
                    else:
                        obsRec.valor=float(row[2])
                        obsRec.unidad=row[3]
                    obsRec.clasificacion = row[4]
                    observaciones.append(obsRec)
                cursor.execute("COMMIT;")
                conex.close()    
                #No data
                if (observaciones.__len__()<=0):
                    bandera="0"

                observaciones = zip(ids, observaciones)


                context = {'observaciones': observaciones,
                    'bandera': bandera,
                    'station': direccion,
                    'stationid': stationid,
                    'latitud': latitud,
                    'longitud': longitud,
                    'clasificacion': clasificacion,
                    'nbar': 'station'}




    # Get info from the station id
    else:

        observaciones = []
        ids = []
        obsRecientes = []
        bandera = "1"
        sql = ""
        direccion = ""
        latitud = ""
        longitud = ""
        clasificacion = ""
        
        conex = conexion()
        cursor = conex.cursor()
       

        cursor.execute(" SET  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;")
        sql = (sql + " select descripcion_"+currentlang+",fecha,valor,unidad,O.clasificacion, E.direccion,"
            " X(coordenadas) as x, Y(coordenadas) as y, E.clasificacion, S.idsensor"
            " from monitoreo.monitoreo_observacion as O INNER JOIN")
        sql = sql + " monitoreo.monitoreo_sensor as S ON O.idsensor = S.idsensor INNER JOIN"
        sql = sql + " monitoreo.monitoreo_estacion as E ON O.idestacion = E.idestacion"
        sql = sql + " WHERE E.idproyecto = "+ settings.ID_PROJECT + " AND E.idestacion=" + str(station) + ";"
        cursor.execute(sql)

        for row in cursor.fetchall():
            ids.append(row[9])
            direccion = row[5]
            latitud = row[6]
            longitud = row[7]
            clasificacion = row[8]
            obsRec = ObservacionesRecientes()
            obsRec.descripcion=row[0]
            obsRec.fecha= row[1].strftime('%d/%m/%Y')
            obsRec.hora=row[1].strftime('%d/%m/%Y %H:%M:%S')
            
            if (float(row[2])==float(-9999)):
                obsRec.valor=""
                obsRec.unidad=""
            else:
                obsRec.valor=float(row[2])
                obsRec.unidad=row[3]
            obsRec.clasificacion = row[4]
            observaciones.append(obsRec)
        cursor.execute("COMMIT;")
        conex.close()    
        
        #No data
        if (observaciones.__len__()<=0):
            bandera="0"

        observaciones = zip(ids, observaciones)


        context = {'observaciones': observaciones,
            'bandera': bandera,
            'station': direccion,
            'stationid': station,
            'latitud': latitud,
            'longitud': longitud,
            'clasificacion': clasificacion,
            'nbar': 'station'}

    return render(request, 'monitoreo/station.html', context)

#Info about compound
def compound(request, station, compound):
    bandera = "1"
    observaciones = []
    formatoFecha = '%Y-%m-%d'
    formatoWeb = '%d/%m/%Y'
    observacion = observacionSensor(station, compound)
    fechaDato = ""
    rango = rangoSensor(compound)

    periodo = date.today() - (date.today()-timedelta(days=1))
    fecha = (date.today()-timedelta(days=1)).strftime(formatoFecha)
    fechaHasta = (date.today()).strftime(formatoFecha)
    fechaWeb = (date.today()-timedelta(days=1)).strftime(formatoWeb)
    fechaWebHasta = (date.today()).strftime(formatoWeb)

    if request.method == 'POST':
        form = BusquedaObservaciones(request.POST)
        if form.is_valid():
            fecha = datetime.strptime((request.POST.get("fecha", "")), formatoWeb)
            fechaHasta = datetime.strptime((request.POST.get("fechaHasta", "")), formatoWeb)
            periodo = fechaHasta - fecha
            fechaWeb = fecha.strftime(formatoWeb)
            fechaWebHasta = fechaHasta.strftime(formatoWeb)
            fecha = fecha.strftime(formatoFecha)
            fechaHasta = fechaHasta.strftime(formatoFecha)


    if(observacion != ""):
        tipoSensor = observacion['abreviatura']
        (observaciones,
            promedio,
            contrador,
            maximo,
            minimo,
            numeroMuestras) = observacionesPorSensor(station, tipoSensor, fecha, fechaHasta)

    contadoreu = 0;
    contadoroms = 0;
    if(rango.__len__() == 4):
        for obser in observaciones:
            if(float(obser.medida) >= float(rango[2]['desde'])):
                contadoroms += 1
            if(float(obser.medida) >= float(rango[3]['desde'])):
                contadoreu += 1

    if(observacion != ""):
        fechaDato = observacion['fecha']
    if(observacion == ""): #No data
        bandera = "0"
    elif(rango.__len__() != 4): #No ranges
        bandera = "2"



    context = {'periodo': periodo.days,
        'contadoroms': contadoroms,
        'contadoreu': contadoreu,
        'fechaDato': fechaDato,
        'fecha': fechaWeb,
        'fechaHasta': fechaWebHasta,
        'observacion': observacion,
        'observaciones': observaciones,
        'rango': rango,
        'bandera': bandera,
        'nbar': 'station'}

    return render(request, 'monitoreo/compound.html', context)

# Frame stations

def frame_station(request, station):
    obs = []
    ids = []
    obsRecientes = []
    bandera = ""
    sql = ""

    currentlang = translation.get_language()
    
    conex = conexion()
    cursor = conex.cursor()
   

    cursor.execute(" SET  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;")
    sql = (sql + " select descripcion_"+currentlang+",fecha,valor,unidad,O.clasificacion, S.idsensor"
        " from monitoreo.monitoreo_observacion as O INNER JOIN")
    sql = sql + " monitoreo.monitoreo_sensor as S ON O.idsensor = S.idsensor INNER JOIN"
    sql = sql + " monitoreo.monitoreo_estacion as E ON O.idestacion = E.idestacion"
    sql = sql + " WHERE E.idproyecto = "+ settings.ID_PROJECT + " AND E.idestacion=" + str(station) + ";"
    cursor.execute(sql)
    
    for row in cursor.fetchall():
        ids.append(row[5])
        obsRec = ObservacionesRecientes()
        obsRec.descripcion=row[0]
        obsRec.fecha= row[1].strftime('%d/%m/%Y')
        obsRec.hora=row[1].strftime('%d/%m/%Y %H:%M:%S')
        
        if (float(row[2])==float(-9999)):
            obsRec.valor=""
            obsRec.unidad=""
        else:
            obsRec.valor=float(row[2])
            obsRec.unidad=row[3]
        obsRec.clasificacion = row[4]
        obs.append(obsRec)
    cursor.execute("COMMIT;")
    conex.close() 
    
    # No data    
    if (obs.__len__()<=0):
        bandera="0"

    obs = zip(ids, obs) 

    return render(request, 'monitoreo/frame_station.html', {'obs': obs,'bandera':bandera,'station': station, 'stationid': station})

# About AirAct

def about(request):
    currentlang = translation.get_language()
    compuestos = []

    conex = conexion()
    cursor = conex.cursor()

    cursor.execute("select descripcion_"+currentlang+", definicion_"+currentlang+
        "  from monitoreo.monitoreo_sensor"
        " where idsensor < 9 AND idsensor > 2"
        " order by descripcion ;" )

    for row in cursor.fetchall():
        compuestos.append({'descripcion': row[0], 'definicion': row[1]})

    context = {'compuestos': compuestos,'nbar': 'about'}
    return render(request, 'monitoreo/about.html', context)

# Get last observation from a sensor
def observacionSensor(estacion, sensor):
    observacion = ""
    currentlang = translation.get_language()

    conex = conexion()
    cursor = conex.cursor()

    cursor.execute("SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;")
    sql = ("select  descripcion_"+currentlang+", fecha, valor, unidad, O.clasificacion, E.direccion, S.abreviatura" +
        " from monitoreo.monitoreo_observacion as O INNER JOIN" +
        " monitoreo.monitoreo_sensor as S ON O.idsensor = S.idsensor INNER JOIN" +
        " monitoreo.monitoreo_estacion as E ON O.idestacion = E.idestacion" +
        " WHERE E.idproyecto = " + settings.ID_PROJECT + " AND E.idestacion = " + str(estacion) +
        " AND O.idsensor = " + sensor + ";")
    cursor.execute(sql)
    rs = cursor.fetchone()
    if(cursor.rowcount != 0):
        observacion = {'compuesto': rs[0],'fecha': rs[1].strftime('%d/%m/%Y %H:%M:%S'),
        'valor': rs[2], 'unidad': rs[3], 'clasificacion': rs[4], 'estacion': rs[5], 'abreviatura': rs[6]}

    cursor.execute("COMMIT;")
    conex.close()

    return observacion

# Get the ranges of a sensor
def rangoSensor(sensor):
    rango = []
    conex = conexion()
    cursor = conex.cursor()

    sql = ("select clasificacion, desde, hasta from monitoreo.monitoreo_rango" +
        " where idsensor = " + str(sensor) + " order by clasificacion;")
    cursor.execute(sql)
    for row in cursor.fetchall():
        rango.append({'limite': row[0], 'desde': row[1], 'hasta': row[2]})

    return rango

# Get observations from Commsensum
def observacionesPorSensor(estacion, tipoSensor, fechainicio, fechafin):
    observaciones = []
    contador=0
    promedio = 0.0
    queryOrden = "ORDER BY ?time"
    queryTiempo = ""
    maximo=0.0
    minimo=99999999999.0
    suma=0.0
    if (fechainicio!="" ):
        queryTiempo = "/samplingTimes/" + fechainicio + "T000000::" + fechafin + "T230000"


    try:
        g = Graph()
        qr= (settings.URL_COMMSENSUM + "observations/projects/" + settings.ID_PROJECT +
            "/observedproperties/" + tipoSensor + "/sensors/" + estacion + queryTiempo)


        headers = {'Accept': 'application/rdf+xml'}
        resp = requests.get(qr, headers=headers)
        g.parse(data=resp.content)



        qres = g.query("SELECT ?time ?val " +
            "WHERE { " +
            "    ?a ssn:observationResultTime ?time . " +
            "    ?a ssn:observationResult ?b . " +
            "    ?b ssn:hasValue ?c . " +
            "    ?c DUL:hasDataValue ?val . " +
            " } "  +
            queryOrden 
            )

        suma =0

        for tiempo, val in qres:
            observacion = Observaciones()
            observacion.tiempo = (utcConvert(tiempo))
            observacion.tiempo = observacion.tiempo.strftime('%Y-%m-%d %H:%M:%S')
            observacion.medida = val
            observaciones.append(observacion)

            if (float(val)>0.0):
                    suma = suma + float(val)
                    contador = contador + 1
                    if (float(maximo)<float(val)):
                        maximo = float(val)
                    if (float(minimo)>float(val)):
                        minimo = float(val)
        if (contador>0):
            promedio = suma/contador



    except Exception as e:
        contador =0
        maximo = 0
        minimo = 0
        promedio = 0
        return observaciones, promedio, contador, maximo, minimo, contador
    else:

        return observaciones, promedio, contador, maximo, minimo, contador

# Get closest station
def estacionCercana(lat, lng):

    idestacion = ""

    conex = conexion()
    cursor = conex.cursor()
    cursor.execute(" SET  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;") 
    sql = "SELECT ( 6371 * ACOS("
    sql = sql + "COS( RADIANS("+lat+") ) "
    sql = sql + "* COS(RADIANS( X(coordenadas) ) ) "
    sql = sql + "* COS(RADIANS( Y(coordenadas) ) "
    sql = sql + "- RADIANS("+lng+") ) "
    sql = sql + "+ SIN( RADIANS("+lat+") ) "
    sql = sql + "* SIN(RADIANS( X(coordenadas) ) ) "
    sql = sql + ") "
    sql = sql + ") AS distance, idestacion "
    sql = sql + "FROM monitoreo.monitoreo_estacion where idproyecto =  " + settings.ID_PROJECT
    sql = sql + " and clasificacion<>'i8' and clasificacion<>'i9' HAVING distance < 100000  "
    sql = sql + "ORDER BY distance ASC LIMIT 1;"

    cursor.execute(sql)
    conex.close()
    rs = cursor.fetchone()
    distancia = "{:10.2f}".format(rs[0])
    idestacion = rs[1]

    return idestacion

# Convert from UTC to Spanish local time
def utcConvert(fecha):
    from_zone = tz.gettz('UTC')
    to_zone = tz.gettz('Europe/Madrid')

    utc = datetime.strptime(fecha, '%Y%m%dT%H%M%SZ')
    
    # Tell the datetime object that it's in UTC time zone since 
    # datetime objects are 'naive' by default
    utc = utc.replace(tzinfo=from_zone)

    # Convert time zone
    central = utc.astimezone(to_zone)
    return central