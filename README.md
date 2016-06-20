# [AirAct](https://iotech.es/)

## Sobre Air Act
Es una plataforma libre que permita mostrar los datos sobre diferentes agentes contaminantes, los riesgos que tienen para la salud y las recomendaciones para mejorar la situación.
Esta plataforma emplea Django conjuntamente con Bootstrap para que sea accesible desde diferentes dispositivos.
Además contiene dos versiones de código en CUDA para computar diagramas de *Vornoi*.
Esta plataforma pertenece a un proyecto europeo H2020, el proyecto [CAPTOR](https://www.captor-project.eu/).

## Objetivos
- **Unificación de datos**. Los datos son publicados de manera individual por las diferentes comunidades autónomas y se pretende unificar en una única plataforma para que los usuarios puedan obtener toda la información de manera conjunta. Para ello se empleará un mapa en el que se situarán las diferentes medidas, indicando las regiones a las que afectan.
- **Accesibilidad**. Para que sea accesible y pueda llegar a una gran cantidad de personas, debe poderse acceder desde múltiples dispositivos y dar soporte a diferentes idiomas.
- Simplicidad. Debe de ser fácil de emplear y entender, ya que está destinada para usuarios expertos y no expertos en la materia medioambiental.
- **Difusión**. Los datos que muestre la plataforma deben poderse compartir en las redes sociales por los usuarios.
- **Escalabilidad**. La plataforma debe ser capaz de soportar un gran número de datos ya que se prevé que no solo será de ámbito nacional.
- **Transparencia**. En todo momento se debe mostrar que límite se ha establecido para informar a los usuarios, ya sea el europeo o el de la OMS.
- **Libre**. Que sea una plataforma libre contribuye a que los voluntarios puedan participar de manera activa para mejorarla.

## Instalación y configuración del entorno
Proceso de instalación para poder ejecutar en un servidor la plataforma Air Act (siendo una distribución basada en debian con el servidor Apache2):

1. Lo primero es clonar el repositorio en el servidor.

    ```$ git clone```
2. Seguidamente se instalan todas los paquetes necesarios para poder ejecturar el servidor.

    ```$ sudo apt-get install python2.7 python-pip python-virtualenv python-mysqldb python-mysql.connector apache2 apache2-mpm-prefork apache2-utils mysql-server libapache2-mod-wsgi```
3. Una vez instalados los paquetes, se crea el entorno virtual y se instalan los paquetes de python del proyecto Air Act, que se encuentran en el archivo pip_requirements.txt.

    ```
    $ virtualenv .
    $ source bin/activate
    $ pip install -r airact/pip_requierements.txt
    ```
4. Ahora hay que crear las tablas de MySQL, para ello se emplea el script del repositorio backup.sql.

    ```
    $ mysql -u root -p < backup.sql
    ```
5. Ahora se tiene que configurar el devSettings.py.template y devMonitoreo.py.template con los datos correspondientes y se deben renombrar quitándoles la extensión .template.
6. Se debe rellenar la base de datos con datos manuales como son los diferentes rangos y configurar el cron para que ejecute tareaMonitoreo.py cada 20 minutos.
    Contenido del cron:

    ```
    */20 * * * * /path/python /path/airact/tareaMonitoreo.py > /path/monitoreo.log
    ```
7. Finalmente se tiene que configurar apache con el mod wsgi. Para ello hay que modificar el fichero de configuración de apache con los siguientes parámetros:
    
    ```
    Alias /static/ /path/to/mysite.com/static/

    <Directory /path/to/mysite.com/static>
    Require all granted
    </Directory>
    
    WSGIScriptAlias / /path/to/mysite.com/mysite/wsgi.py
    WSGIPythonPath /path/to/mysite.com

    <Directory /path/to/mysite.com/mysite>
    <Files wsgi.py>
    Require all granted
    </Files>
    </Directory>
    ```
Opcionalmente se puede añadir un certificado SSL. Permitiendo así utilizar la opción de geolocalización.

Adicionalmente, si se quieren ejecutar los experimentos se debe modificar en el makefile los paths para compilar y los archivos de los jobs, modificando también el path. Una vez realizadas estas modificaciones, ya se pueden emplear las funciones del makefile para compilar y enviar ejecuciones a la cola.


