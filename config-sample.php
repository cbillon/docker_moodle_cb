<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'docker_moodle-db';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'admin';
$CFG->dbpass    = 'sesame';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

$CFG->wwwroot   = 'http://localhost:8088';
$CFG->dataroot  = '/var/www/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

//$CFG->debug = E_ALL;
//$CFG->debugdisplay = 1;

//   Redis session handler (requires redis server and redis extension):
$CFG->session_handler_class = '\core\session\redis';
$CFG->session_redis_host = 'docker_moodle-redis';
$CFG->session_redis_port = 6379;  // Optional.
//      $CFG->session_redis_database = 0;  // Optional, default is db 0.
//      $CFG->session_redis_auth = ''; // Optional, default is don't set one.
//      $CFG->session_redis_prefix = ''; // Optional, default is don't set one.
//      $CFG->session_redis_acquire_lock_timeout = 120;
//      $CFG->session_redis_lock_expire = 7200;
//      $CFG->session_redis_lock_retry = 100; // Optional wait between lock attempts in ms, default is 100.
//                                            // After 5 seconds it will throttle down to once per second.
//      Use the igbinary serializer instead of the php default one. Note that phpredis must be compiled with
//      igbinary support to make the setting to work. Also, if you change the serializer you have to flush the database!
//      $CFG->session_redis_serializer_use_igbinary = false; // Optional, default is PHP builtin serializer.
//      $CFG->session_redis_compressor = 'none'; // Optional, possible values are:
//                                               // 'gzip' - PHP GZip compression
//                                               // 'zstd' - PHP Zstandard compression

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!