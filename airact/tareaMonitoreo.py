import MySQLdb
from rdflib import Graph
import dateutil.parser
import requests
from unicodedata import normalize
from dateutil import tz
from datetime import datetime
import facebook

try:
    from devMonitoreo import *
except ImportError:
    print "devMonitoreo.py ImportError!"
    print "Probably file doesn't exist,"
    print "this file must contain some project private data and must not be shared in the repository."
    print "Please copy 'devMonitoreo.py.template' to 'devMonitoreo.py' with your project's data."


class Rango:
    id = 1
    desde = 0.0
    hasta =  10.0
    clasificacion = ""
class Notificacion:
    idSensor =0
    tipo=""
    limite=0
    plantilla=""
class Medida:
    idEstacion = 0
    idSensor = 0
    descripcion = ""
    abreviatura = ""
    valor = 0.0
    unidad = ""
    fechahora = "2000-01-01 10:10:10"
    direccion=""
    latitud=0.0
    longitud=0.0
class Destinatario:
    mail =""
    
def funcion():
    print (datetime.now())
    urlBase = "http://commsensum.pc.ac.upc.edu:3000/"
    idProyecto = "8"
    uri = urlBase  + 'sensors/project/' + idProyecto
    #============================ Get ranges =============================================
    db = conexion()
    sql = ""
    cursor = db.cursor()
    cursor.execute('SELECT * FROM monitoreo.monitoreo_rango ')
    rangos = []
    for row in cursor.fetchall():
        rango = Rango()
        rango.id = row[0]
        rango.desde = row[1]
        rango.hasta = row[2]
        rango.clasificacion = row[3]
        rangos.append(rango)
    #============================ Get notifications=============================================
    cursor = db.cursor()
    cursor.execute('SELECT idsensor,tipo,limite,plantilla FROM monitoreo.monitoreo_notificacion')
    notificacion = []
    
    idSensor =0
    tipo=""
    limite=0
    plantilla=""
    for row in cursor.fetchall():
        notif = Notificacion()
        notif.idSensor = row[0]
        notif.tipo = row[1]
        notif.limite = row[2]
        notif.plantilla = row[3]
        notificacion.append(notif)
    
    #================================== Get recipients ===================================
    sql = "SELECT direccion FROM monitoreo.monitoreo_mail WHERE tipo ='ERRORTAREAAUTO'"
    cursor = db.cursor()
    cursor.execute(sql)
    destinatarios = []
    for row in cursor.fetchall():
        dest = Destinatario()
        dest.mail = row[0]
        destinatarios.append(dest)

    db.close()
    #================================ Get stations porperties ===========================
    p = Graph()
    headers = {'Accept': 'application/rdf+xml',}
    resp = requests.get(uri, headers=headers,  timeout=100000)
    resp.encoding='utf8'
    p.parse(data=resp.content)
    qresp = p.query(
        '''
        SELECT ?s ?op ?lab ?date ?val ?uni ?comm ?lati ?long ?addr
        WHERE {
        ?s a ssn:SensingDevice .
        ?s ssn:hasDeployment ?x .
        ?x ssn:deployedOnPlatform ?b .
        ?b DUL:hasLocation ?c .
        ?c geo:lat ?lati .
        ?c geo:long ?long .
        ?b DUL:hasLocation ?d .
        ?d addr:thoroughfareName ?addr .
        ?s ssn:hasMeasurementCapability ?mc .
        ?mc ?prop ?li .
        ?li rdf:type ssn:propertyWithLastObservation .
        ?li ssn:observedProperty ?op .
        ?li ssn:lastObservation ?obs .
        ?obs ssn:observationResultTime ?date .
        ?obs ssn:observationResult ?so .
        ?so ssn:hasValue ?amount .
        ?amount DUL:hasDataValue ?val .
        ?amount DUL:isClassifiedBy ?unitsId .
        ?op rdfs:label ?lab .
        ?unitsId  rdfs:comment ?comm .
        ?unitsId  rdfs:label ?uni .
        }   ''')
    medidas = []
    
    print ("Parser end " + str(datetime.now()))
    contador=0
    for row in qresp:
        medida = Medida()
        arregloId = row["s"].split("/")
        id = arregloId[len(arregloId) -1]
        medida.idEstacion = id
        arregloId = row["op"].split("/")
        id = arregloId[len(arregloId) -1]
        medida.idSensor = id
        medida.descripcion = normalize('NFKD', ( row["comm"].replace ("'"," "))).encode('ASCII', 'ignore')
        medida.abreviatura = normalize('NFKD', ( row["lab"].replace ("'"," "))).encode('ASCII', 'ignore')
        if (str(row["val"])=="nan"):
            medida.valor=-9999
        else:
            medida.valor = row["val"]
        medida.unidad = normalize('NFKD', ( row["uni"].replace ("'"," "))).encode('ASCII', 'ignore')
        medida.fechahora =  row["date"]
        medida.direccion =   normalize('NFKD', ( row["addr"].replace ("'"," "))).encode('ASCII', 'ignore')
        medida.latitud = row["lati"]
        medida.longitud = row["long"]
        medidas.append(medida)
        
    print ("Load end " + str(datetime.now()))    

    #============================Get stations=======================================
    cadenaMensaje = ""
    IdsEstacion = {}
    for obj in medidas:
        IdsEstacion[obj.idEstacion] = obj
    try:
        for idEstacion in IdsEstacion:
             db = conexion()
             cursor = db.cursor()
             #====================== Filter sensors==================================

             medidasSensor = filter(lambda x: x.idEstacion  == idEstacion, medidas)
             clasificacionesSensores=[]

             

             for fila in medidasSensor:
                #============== Search stations====================================
                contadorEstacion=0
                sql = ("SELECT count(idestacion)"
                    " from monitoreo.monitoreo_estacion"
                    " WHERE idestacion=" +str(idEstacion) + " and idproyecto=" + idProyecto)
                cursor.execute(sql)
                for row in cursor.fetchall():
                   contadorEstacion=int(row[0])
                if contadorEstacion==0:
                    #===============Insert Station=================================
                    sql = ("INSERT INTO monitoreo.monitoreo_estacion(idestacion,clasificacion,"
                        " idproyecto, direccion, coordenadas)"
                        " VALUES(" +str(idEstacion) +  ",''," + idProyecto + ",'" + fila.direccion +
                        "',PointFromText(CONCAT('POINT('," + str(fila.latitud) +
                        ",' '," + str(fila.longitud) + ",')')) )")
                else:
                    sql = ("UPDATE monitoreo.monitoreo_estacion"
                        " SET clasificacion='',direccion='"+fila.direccion+"',"
                        " coordenadas=PointFromText(CONCAT('POINT(',"+str(fila.latitud)+",' ',"+
                        str(fila.longitud)+",')'))"
                        " WHERE idestacion=" + str(idEstacion) + " and idproyecto = " + idProyecto)
                 
                cursor.execute(sql)
                
                db.commit()

                #===============Insert Sensors====================================
                fecha = dateutil.parser.parse(fila.fechahora)
                fecha =utcConvert(str(fecha.strftime('%Y-%m-%d %H:%M:%S')))
                #===============Determinclasification based on the ranges==========
                clasificacion = ""
                clasificacion = clasificaMedida(rangos, fila.idSensor, fila.valor, fecha)
                if (clasificacion!=""):
                    clasificacionesSensores.append(int(clasificacion.replace("i","")))

                #===============Determine notiications=============================
                retornoMensaje =""
                retornoMensaje = verificarNotificaciones(
                    db,
                    cursor,
                    notificacion,
                    fila.idEstacion,
                    fila.idSensor,
                    fila.valor, 
                    fecha,
                    fila.direccion)
                if (retornoMensaje!=""):
                    cadenaMensaje= cadenaMensaje  + str(retornoMensaje)  
                


                #==================Insert or update properties=====================
                contadorPropiedades=0
                sql = ("SELECT count(idsensor)"
                    " from monitoreo.monitoreo_sensor"
                    " WHERE idsensor=" +str(fila.idSensor))
                cursor.execute(sql)
                for row in cursor.fetchall():
                    contadorPropiedades=int(row[0])
                descripcionSensor = fila.descripcion.replace ("'","")
                if contadorPropiedades==0:
                    sql = "INSERT INTO monitoreo.monitoreo_sensor(idsensor,"
                    " abreviatura, descripcion, unidad) "
                    sql = (sql + "VALUES(" + fila.idSensor +  ",'" +
                        fila.abreviatura +  "','" +
                        descripcionSensor +  "','" +
                        fila.unidad +  "')")
                else:
                    sql = "UPDATE monitoreo.monitoreo_sensor SET "
                    sql = (sql + "abreviatura='"  + fila.abreviatura +
                        "',descripcion='" + descripcionSensor +
                        "',unidad='" + fila.unidad +  "'")
                    sql = sql + " WHERE  idsensor=" + fila.idSensor 

                try:
                    cursor.execute(sql)

                    db.commit()
                    
                except BaseException as e:
                    print ("Error database sql:" + sql)

                #===============Insert or update observations===================
                contadorSensores=0

                sql = "SELECT count(O.idestacion) from "
                sql =  (sql + " monitoreo.monitoreo_observacion as O"
                    " INNER JOIN monitoreo.monitoreo_sensor as S"
                    " ON O.idsensor = S.idsensor INNER JOIN ")
                sql =  (sql + " monitoreo.monitoreo_estacion as E"
                    " ON O.idestacion = E.idestacion"
                    " WHERE E.idproyecto = "+idProyecto+
                    " AND E.idestacion=" +str(fila.idEstacion) +
                    " AND O.idsensor=" + fila.idSensor + ";")
                cursor.execute(sql)
                for row in cursor.fetchall():
                    contadorSensores=int(row[0])

                if contadorSensores==0:
                    sql = ("INSERT INTO monitoreo.monitoreo_observacion(idestacion, idsensor,"
                        "  valor, fecha, clasificacion) ")
                    sql = (sql + "VALUES(" +str(fila.idEstacion) +  "," +
                        fila.idSensor +  "," +
                        str(fila.valor) +  ",'" +
                        fecha.strftime('%Y/%m/%d %H:%M:%S')+  "' , '"+
                        clasificacion+"')")
                    
                    
                else:
                    sql = "UPDATE monitoreo.monitoreo_observacion SET "
                    sql = (sql + " valor=" + str(fila.valor) +
                        ",fecha='" + fecha.strftime('%Y/%m/%d %H:%M:%S')+
                        "' , clasificacion='"+clasificacion+"' ")
                    sql = (sql + " WHERE idestacion=" +str(fila.idEstacion) +
                        "  and idsensor=" + fila.idSensor )
                    
                 

                try:
                    cursor.execute(sql)
                    
                    db.commit()
                except BaseException as e:
                    print ("Error database sql:" + sql) 
             #================== Update station ==============================
             clasificacionEstacion=""
             clasificacionMayor = 0
             if (clasificacionesSensores.__len__()>0):
                 clasificacionMayor = max(clasificacionesSensores, key=lambda x:int(x))

             if (clasificacionMayor!=0):
                 clasificacionEstacion= "i" + str(clasificacionMayor)
             else:
                 clasificacionEstacion= "i8"
             sql = ("UPDATE monitoreo.monitoreo_estacion SET clasificacion='" + clasificacionEstacion +
                "' WHERE idestacion=" + str(idEstacion) + " and idproyecto = " + idProyecto)
             cursor.execute(sql)
             db.commit()
             
             db.close()

    except BaseException as e:
        # mail(destinatarios,
        #     "ERRORTAREAAUTO",
        #     "El proceso de obtencion de informacion no se ha completado. Ultimo sql desarrollo:" + sql +
        #     ". Args:" + str(e.args).replace(",",""))
        print("Ultimo sql desarrollo:" + sql + ". Args:" + str(e.args) + "." + str(e) )

    else:
        # mail(destinatarios,
        #     "ERRORTAREAAUTO",
        #     "El proceso de obtencion de informacion se ha realizado sin inconvenientes. ")
        print((datetime.now()))

    if(cadenaMensaje!="" and REDES_SOCIALES=='Y'):
        notificarFacebook(cadenaMensaje,destinatarios)
        notificarTwitter(cadenaMensaje,destinatarios)
    else:
        print("Sin redes sociales")
        #mail(destinatarios, "", cadenaMensaje)


def clasificaMedida(rangos, idSensor, valor, fechahora):
    clasificacion=""
    rang= filter(lambda x: x.id  == float(idSensor) and 
        x.desde  <= float(valor) and x.hasta  > float(valor) , rangos)
    for rango in rang:
        
        clasificacion = rango.clasificacion
    if (clasificacion!=""):
        fechaUltimaMedida = fechahora.replace(tzinfo=None)
        fechaAhora = datetime.now()
        delta = fechaAhora - fechaUltimaMedida
        tiempoAlerta=4 
        if (delta.days>tiempoAlerta):
            clasificacion= "i9"

       
    return clasificacion


def verificarNotificaciones(db,cursor, tiposNotificacion,idEstacion, idSensor, valor, fechahora, direccion):
    fechaUltimaMedida = fechahora.replace(tzinfo=None)
    contador = 0
    sql = ""
    cadenaRetorno= ""
    notifSensor = filter(lambda x: x.idSensor  == float(idSensor) and x.limite  <= float(valor), tiposNotificacion)
    for tipo in notifSensor:
        cadenaMensaje =  tipo.plantilla.replace("(VALOR)",
            str(valor)).replace("(FECHA)",str(fechaUltimaMedida)).replace("(LIMITE)",str(tipo.limite))
        sql = ("SELECT count(idsensor) from monitoreo.monitoreo_mensaje"
            " WHERE idestacion=" +str(idEstacion) +
            " and idSensor=" + str(idSensor) +
            " and fecha='" + str(fechaUltimaMedida) +
            "' and tipo='"+ tipo.tipo +"';")
        cursor.execute(sql)
        for row in cursor.fetchall():
           contador=int(row[0])
        if (contador==0):
             #===============Insert notifcation=================================
             sql = ("INSERT INTO monitoreo.monitoreo_mensaje(idestacion,idsensor, fecha, valor,tipo, mensaje)"
                " VALUES(" +str(idEstacion) + "," +
                str(idSensor) +  ",'" +
                str(fechaUltimaMedida)+ "'," +
                str(valor) + ",'" +
                tipo.tipo  + "','" +
                cadenaMensaje + "');")
             cursor.execute(sql)
             db.commit()
             cadenaRetorno = (cadenaRetorno +  str(fechaUltimaMedida) +
                " - Estacion:" + direccion + ". " + cadenaMensaje + "\n")
    return cadenaRetorno

             
                


    
import smtplib

def notificarFacebook(cadenaMensaje, destinatarios):
    try:
         graph = facebook.GraphAPI(FBGRAPHAPI)
         profile = graph.get_object("me")
         friends = graph.get_connections("me", "friends")
         #push notification
         graph.put_object(FBPARENTOBJECT, "feed", message="Avisos:"+ "\n"+(cadenaMensaje)) 
         

    except Exception as e:
         print ("Error al notificar en facebook:" + cadenaMensaje + str(e.args) + str(e))
         mail(destinatarios,"ERRORTAREAAUTONOTIFICA",
            "no se pudo publicar en facebook" + cadenaMensaje +
            ".  Args:" + str(e.args).replace(",",""))

import twitter

def notificarTwitter(cadenaMensaje, destinatarios):
    try:
        api = twitter.Api(consumer_key=TWCONSUMERKEY,
          consumer_secret=TWCONSUMERSECRET,
          access_token_key=TWACCESTOKENKEY,
          access_token_secret=TWACCESTOKENSECRET)
        mensaje = "Infracciones Detalles.(http://airelimpio.pc.ac.upc.edu/)." + cadenaMensaje
        status = api.PostUpdate(mensaje[:140]) #Push notification
    except Exception as e:
        print ("Error al notificar en twitter:" + cadenaMensaje + str(e.args) + str(e))
        mail(destinatarios,"ERRORTAREAAUTONOTIFICA",
            "no se pudo publicar en twitter" + cadenaMensaje + ".  Args:" + str(e.args).replace(",",""))


def mail(destinatarios,tipo,mensaje):
    remitente = MAILFROM
    for dest in destinatarios:
        asunto = "Monitoreo Commsensum"
        email = """\
From: %s
To: %s
Content-type: text/html
Subject: Monitoreo Commsensum

<b>Proceso de actualizacion Monitoreo Commsensum</b> 
%s""" % (remitente, dest.mail, mensaje)
        try:
            smtp = smtplib.SMTP('smtp.gmail.com',587)
            smtp.ehlo()
            smtp.starttls()
            smtp.login(MAILFROM, MAILPASS)
            smtp.sendmail(remitente, dest.mail, email)
            smtp.close()
            print("Mail sent")
        except  BaseException as e:
            print ("Error envio Mail: " + str(e))


def conexion():
    return MySQLdb.connect(user=DBUSER, db=DBNAME, passwd=DBPASS, host=DBHOST)

def utcConvert(fecha):
    from_zone = tz.gettz('UTC')
    to_zone = tz.gettz('Europe/Madrid')

    # utc = datetime.utcnow()
    utc = datetime.strptime(fecha, '%Y-%m-%d %H:%M:%S')
    
    # Tell the datetime object that it's in UTC time zone since 
    # datetime objects are 'naive' by default
    utc = utc.replace(tzinfo=from_zone)

    # Convert time zone
    central = utc.astimezone(to_zone)
    return central

funcion()

