-- MySQL dump 10.13  Distrib 5.7.12, for Linux (x86_64)
--
-- Host: localhost    Database: monitoreo
-- ------------------------------------------------------
-- Server version	5.7.12-0ubuntu1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `monitoreo`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `monitoreo` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `monitoreo`;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_time` datetime NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_417f1b1c` (`content_type_id`),
  KEY `django_admin_log_e8701ad4` (`user_id`),
  CONSTRAINT `djang_content_type_id_697914295151027a_fk_django_content_type_id` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_52fdd58701c5f563_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_45f3b1d93ec8c61c_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(4,'auth','user'),(5,'contenttypes','contenttype'),(8,'monitoreo','estacion'),(13,'monitoreo','mails'),(12,'monitoreo','mensaje'),(11,'monitoreo','notificacion'),(10,'monitoreo','observacion'),(7,'monitoreo','rango'),(9,'monitoreo','sensor'),(6,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_migrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2014-11-18 21:53:09'),(2,'auth','0001_initial','2014-11-18 21:53:09'),(3,'admin','0001_initial','2014-11-18 21:53:11'),(4,'sessions','0001_initial','2014-11-18 21:53:11'),(5,'admin','0002_logentry_remove_auto_add','2016-06-09 21:36:36'),(6,'contenttypes','0002_remove_content_type_name','2016-06-09 21:36:36'),(7,'auth','0002_alter_permission_name_max_length','2016-06-09 21:36:36'),(8,'auth','0003_alter_user_email_max_length','2016-06-09 21:36:36'),(9,'auth','0004_alter_user_username_opts','2016-06-09 21:36:36'),(10,'auth','0005_alter_user_last_login_null','2016-06-09 21:36:36'),(11,'auth','0006_require_contenttypes_0002','2016-06-09 21:36:36'),(12,'auth','0007_alter_validators_add_error_messages','2016-06-09 21:36:36'),(13,'monitoreo','0001_initial','2016-06-09 21:37:59');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_de54fa62` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('3l6c72wehotbkpzn96aw0sef6bdh9rcp','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2015-11-30 16:42:03'),('50rbgcuuhx9dku3zykn990t84yro0jlz','NGExNzQ3NWY0Y2MxZjJlMmY1NmVhYTQ5MjczZDI2YjdmZDZjMjM5YTp7Il9sYW5ndWFnZSI6ImVuIn0=','2016-02-08 08:04:50'),('5k6zsag4a9nh430js2dyjpycxn9kh77g','NGExNzQ3NWY0Y2MxZjJlMmY1NmVhYTQ5MjczZDI2YjdmZDZjMjM5YTp7Il9sYW5ndWFnZSI6ImVuIn0=','2015-01-01 15:59:37'),('5v5hdddz0q2gg7s82znald04ga23h2pa','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2016-05-26 08:47:33'),('fr2j9i90tvxviocqw8k3ojiocagpyeqg','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2016-05-10 10:33:01'),('fyivy12ka10es0m06a83mxz95xjezc53','NGExNzQ3NWY0Y2MxZjJlMmY1NmVhYTQ5MjczZDI2YjdmZDZjMjM5YTp7Il9sYW5ndWFnZSI6ImVuIn0=','2014-12-10 15:34:09'),('ghffa54zl72vyu97nbe0wwx82wwepqfp','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2015-02-06 09:17:34'),('h03dg4qeqe3hwwsb9b5nccmarm32ks2f','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2015-10-29 12:57:31'),('ign81v5cne0qw5pw9xhn9lh8afroy9mv','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2015-11-15 23:32:25'),('jkq2lrez9j7o2066b987duoqnb5zhxr8','NGExNzQ3NWY0Y2MxZjJlMmY1NmVhYTQ5MjczZDI2YjdmZDZjMjM5YTp7Il9sYW5ndWFnZSI6ImVuIn0=','2014-12-05 15:37:33'),('lmpclbs5rl2xv5ui3ug4kgtzz1p5lfl4','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2015-06-02 15:43:14'),('ly1d05ufvqbsswcpvaj7cnmefyniihrq','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2015-11-16 21:09:15'),('mxi29prkhuzf8fybn3ef80rh2yfiis1n','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2015-01-30 19:27:02'),('nxckm2yg6hwer7yub6lcfgwkof1nvks3','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2014-12-31 18:03:57'),('o2yhx53ima9ijvxz9em6fb1nq40dhb37','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2015-01-01 10:08:33'),('pp8n0o1y2e7v9km2cumlsw9dcs7byi31','MzgzNTIwZWJhMWE2MDEyYmNhYTlkOTlhMzA2ZDNjODg1OTc2ODM4MDp7fQ==','2015-02-13 00:10:00'),('q4fiwmtmkwd930u22mn7rfay6mve88tz','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2016-03-06 18:47:27'),('sfbjjc4bktgxro96vrr8lqrwymdxk1lc','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2015-06-02 15:48:57'),('tck6gccxiqttf5i81k62uic8sc660nt1','NGExNzQ3NWY0Y2MxZjJlMmY1NmVhYTQ5MjczZDI2YjdmZDZjMjM5YTp7Il9sYW5ndWFnZSI6ImVuIn0=','2015-01-23 00:19:05'),('woarsnrh5r1pl6u1s0u412hhn93amhex','YzIzMTA4YjFmYTRjNGY3NWYyNWU0OGNmMzQ2ZTNjNTAzNTc0MTk2ZDp7Il9sYW5ndWFnZSI6ImVzIn0=','2014-12-26 15:14:54');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monitoreo_estacion`
--

DROP TABLE IF EXISTS `monitoreo_estacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitoreo_estacion` (
  `idestacion` int(11) NOT NULL,
  `idproyecto` int(11) NOT NULL,
  `clasificacion` varchar(10) NOT NULL,
  `coordenadas` point DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`idestacion`,`idproyecto`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monitoreo_estacion`
--

LOCK TABLES `monitoreo_estacion` WRITE;
/*!40000 ALTER TABLE `monitoreo_estacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `monitoreo_estacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monitoreo_mail`
--

DROP TABLE IF EXISTS `monitoreo_mail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitoreo_mail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` varchar(30) NOT NULL,
  `direccion` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monitoreo_mail`
--

LOCK TABLES `monitoreo_mail` WRITE;
/*!40000 ALTER TABLE `monitoreo_mail` DISABLE KEYS */;
/*!40000 ALTER TABLE `monitoreo_mail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monitoreo_mensaje`
--

DROP TABLE IF EXISTS `monitoreo_mensaje`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitoreo_mensaje` (
  `idestacion` int(11) NOT NULL,
  `idsensor` int(11) NOT NULL,
  `fecha` datetime NOT NULL,
  `tipo` varchar(20) NOT NULL,
  `valor` double NOT NULL,
  `mensaje` text NOT NULL,
  PRIMARY KEY (`idestacion`,`idsensor`,`fecha`,`tipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monitoreo_mensaje`
--

LOCK TABLES `monitoreo_mensaje` WRITE;
/*!40000 ALTER TABLE `monitoreo_mensaje` DISABLE KEYS */;
/*!40000 ALTER TABLE `monitoreo_mensaje` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monitoreo_notificacion`
--

DROP TABLE IF EXISTS `monitoreo_notificacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitoreo_notificacion` (
  `idsensor` int(11) NOT NULL,
  `tipo` varchar(20) NOT NULL,
  `limite` double NOT NULL,
  `plantilla` text NOT NULL,
  PRIMARY KEY (`idsensor`,`tipo`),
  KEY `fk_monitoreo_notificacion_monitoreo_sensor1` (`idsensor`),
  CONSTRAINT `fk_monitoreo_notificacion_monitoreo_sensor1` FOREIGN KEY (`idsensor`) REFERENCES `monitoreo_sensor` (`idsensor`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monitoreo_notificacion`
--

LOCK TABLES `monitoreo_notificacion` WRITE;
/*!40000 ALTER TABLE `monitoreo_notificacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `monitoreo_notificacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monitoreo_observacion`
--

DROP TABLE IF EXISTS `monitoreo_observacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitoreo_observacion` (
  `idestacion` int(11) NOT NULL,
  `idsensor` int(11) NOT NULL,
  `valor` double NOT NULL,
  `fecha` datetime NOT NULL,
  `clasificacion` varchar(10) NOT NULL,
  PRIMARY KEY (`idestacion`,`idsensor`),
  KEY `fk_monitoreo_observacion_monitoreo_sensor1` (`idsensor`),
  KEY `fk_monitoreo_observacion_monitoreo_estacion1` (`idestacion`),
  CONSTRAINT `fk_monitoreo_observacion_monitoreo_estacion1` FOREIGN KEY (`idestacion`) REFERENCES `monitoreo_estacion` (`idestacion`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_monitoreo_observacion_monitoreo_sensor1` FOREIGN KEY (`idsensor`) REFERENCES `monitoreo_sensor` (`idsensor`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monitoreo_observacion`
--

LOCK TABLES `monitoreo_observacion` WRITE;
/*!40000 ALTER TABLE `monitoreo_observacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `monitoreo_observacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monitoreo_rango`
--

DROP TABLE IF EXISTS `monitoreo_rango`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitoreo_rango` (
  `idsensor` int(11) NOT NULL,
  `desde` double NOT NULL,
  `hasta` double NOT NULL,
  `clasificacion` varchar(20) NOT NULL,
  PRIMARY KEY (`idsensor`,`desde`),
  KEY `fk_monitoreo_rango_monitoreo_sensor1` (`idsensor`),
  CONSTRAINT `fk_monitoreo_rango_monitoreo_sensor1` FOREIGN KEY (`idsensor`) REFERENCES `monitoreo_sensor` (`idsensor`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monitoreo_rango`
--

LOCK TABLES `monitoreo_rango` WRITE;
/*!40000 ALTER TABLE `monitoreo_rango` DISABLE KEYS */;
/*!40000 ALTER TABLE `monitoreo_rango` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monitoreo_sensor`
--

DROP TABLE IF EXISTS `monitoreo_sensor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `monitoreo_sensor` (
  `idsensor` int(11) NOT NULL,
  `abreviatura` varchar(20) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `unidad` varchar(10) NOT NULL,
  `definicion` text,
  `descripcion_ca` varchar(100) DEFAULT NULL,
  `definicion_ca` text,
  `descripcion_es` varchar(100) DEFAULT NULL,
  `definicion_es` text,
  `descripcion_en` varchar(100) DEFAULT NULL,
  `definicion_en` text,
  PRIMARY KEY (`idsensor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monitoreo_sensor`
--

LOCK TABLES `monitoreo_sensor` WRITE;
/*!40000 ALTER TABLE `monitoreo_sensor` DISABLE KEYS */;
/*!40000 ALTER TABLE `monitoreo_sensor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'monitoreo'
--

--
-- Dumping routines for database 'monitoreo'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-06-17 15:51:43
