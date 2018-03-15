version: '2'
volumes:
{{- if eq .Values.VOLUME_DRIVER "rancher-nfs" }}
  django-static-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  django-postgis-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  sftpbackup-media-history-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  django-postgis-dbbackup-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  sftpbackup-postgis-target-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  django-realtime-indicator:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  sftpbackup-postgis-history-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  django-media-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain

  sftp-ssh-config-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  analysis-context-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  hazard-drop-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  ashmaps-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  floodmaps-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  shakemaps-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  shakemaps-corrected-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  sftp-ssh-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain

  report-template-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain
  headless-output-data:
    driver: ${VOLUME_DRIVER}
    driver_opts:
      onRemove: retain

{{- else}}

  django-static-data:
    driver: ${VOLUME_DRIVER}
  django-postgis-data:
    driver: ${VOLUME_DRIVER}
  sftpbackup-media-history-data:
    driver: ${VOLUME_DRIVER}
  django-postgis-dbbackup-data:
    driver: ${VOLUME_DRIVER}
  sftpbackup-postgis-target-data:
    driver: ${VOLUME_DRIVER}
  django-realtime-indicator:
    driver: ${VOLUME_DRIVER}
  sftpbackup-postgis-history-data:
    driver: ${VOLUME_DRIVER}
  django-media-data:
    driver: ${VOLUME_DRIVER}

  sftp-ssh-config-data:
    driver: ${VOLUME_DRIVER}
  analysis-context-data:
    driver: ${VOLUME_DRIVER}
  hazard-drop-data:
    driver: ${VOLUME_DRIVER}
  ashmaps-data:
    driver: ${VOLUME_DRIVER}
  floodmaps-data:
    driver: ${VOLUME_DRIVER}
  shakemaps-data:
    driver: ${VOLUME_DRIVER}
  shakemaps-corrected-data:
    driver: ${VOLUME_DRIVER}
  sftp-ssh-data:
    driver: ${VOLUME_DRIVER}

  report-template-data:
    driver: ${VOLUME_DRIVER}
  headless-output-data:
    driver: ${VOLUME_DRIVER}
{{- end}}
services:
  ssh-config-migrate:
    image: kartoza/btsync:rancher
    environment:
      SECRET: ${SSH_CONFIG_SYNC}
      DEVICE: ${SYNC_DEVICE_PREFIX} - SSH Config
      STANDBY_MODE: 'TRUE'
    volumes:
    - sftp-ssh-config-data:/web
    links:
    - sftp:sftp
    labels:
      io.rancher.container.pull_image: always

  ssh-data-migrate:
    image: kartoza/btsync:rancher
    environment:
      SECRET: ${SSH_DATA_SYNC}
      DEVICE: ${SYNC_DEVICE_PREFIX} - SSH Data
      STANDBY_MODE: 'TRUE'
    volumes:
    - sftp-ssh-data:/web
    links:
    - sftp:sftp
    labels:
      io.rancher.container.pull_image: always

{{- if eq .Values.MEDIA_ALLOW_SYNC "true" }}
  media-migrate:
    image: kartoza/btsync:rancher
    environment:
      SECRET: ${MEDIA_SYNC}
      DEVICE: ${SYNC_DEVICE_PREFIX} - Media
      STANDBY_MODE: 'TRUE'
    volumes:
    - django-media-data:/web
    links:
    - uwsgi:uwsgi
    labels:
      io.rancher.container.pull_image: always
{{- end}}

  sftppgbackup:
    image: kartoza/sftp-backup:1.0
    environment:
      DAILY: '14'
      DUMPPREFIX: PG_inasafedjango
      MONTHLY: '12'
      SFTP_DIR: /
      SFTP_HOST: 192.168.1.5
      SFTP_PASSWORD: password
      SFTP_USER: user
      TARGET_FOLDER: /pg_backup
      USE_SFTP_BACKUP: 'False'
      YEARLY: '3'
    volumes:
    - sftpbackup-postgis-history-data:/backups
    - sftpbackup-postgis-target-data:/pg_backup
    links:
    - db:db

  smtp:
    image: catatnight/postfix
    environment:
      maildomain: kartoza.com
      smtp_user: noreply:docker

  sftpmediabackup:
    image: kartoza/sftp-backup:1.0
    environment:
      DAILY: '3'
      DUMPPREFIX: MEDIA_inasafedjango
      MONTHLY: '2'
      SFTP_DIR: /
      SFTP_HOST: 192.168.1.5
      SFTP_PASSWORD: password
      SFTP_USER: user
      TARGET_FOLDER: /media_backup
      USE_SFTP_BACKUP: 'False'
      YEARLY: '1'
    volumes:
    - sftpbackup-media-history-data:/backups
    - django-media-data:/media_backup
    links:
    - uwsgi:uwsgi

  web:
    image: kartoza/inasafe-django_nginx:develop_v4
    command: prod
    volumes:
    - django-static-data:/home/web/static:ro
    - django-media-data:/home/web/media:ro
    links:
    - uwsgi:uwsgi
    ports:
    - ${WEBSERVER_PORT}:8080/tcp

  indicator-worker:
    image: kartoza/inasafe-django_uwsgi:develop_v4
    environment:
      BROKER_URL: amqp://guest:guest@rabbitmq:5672/
      C_FORCE_ROOT: 'true'
      DATABASE_HOST: db
      DATABASE_NAME: ${POSTGRES_DB}
      DATABASE_PASSWORD: ${POSTGRES_PASS}
      DATABASE_USERNAME: ${POSTGRES_USER}
      DJANGO_SETTINGS_MODULE: core.settings.prod_docker
      INASAFE_REALTIME_BROKER_URL: amqp://guest:guest@rabbitmq:5672/
      INASAFE_HEADLESS_BROKER_URL: amqp://guest:guest@rabbitmq:5672/
      INASAFE_OUTPUT_DIR: /home/headless/outputs
      INAWARE_HOST: ${INAWARE_HOST}
      INAWARE_PASS: ${INAWARE_PASS}
      INAWARE_USER: ${INAWARE_USER}
      LOGGING_DEFAULT_HANDLER: console
      LOGGING_DEFAULT_LOG_LEVEL: INFO
      LOGGING_MAIL_ADMINS: 'False'
      LOGGING_SENTRY: 'False'
      MAPQUEST_MAP_KEY: ''
      PYTHONPATH: /home/web/django_project
      SECRET_KEY: +pf&)&(+gqk+w)1szqvqd33=$$&dd4+t$$34+2ka=ct1zas5ddv%
      SITE_DOMAIN_NAME: ${SITE_DOMAIN_NAME}
    working_dir: /home/web/django_project
    volumes:
    - django-static-data:/home/web/static
    - django-media-data:/home/web/media
    - django-realtime-indicator:/home/web/django_project/.run
    - hazard-drop-data:/home/realtime/hazard-drop
    - shakemaps-data:/home/realtime/shakemaps
    - shakemaps-corrected-data:/home/realtime/shakemaps-corrected
    - floodmaps-data:/home/realtime/floodmaps
    - ashmaps-data:/home/realtime/ashmaps
    - headless-output-data:/home/headless/outputs
    - analysis-context-data:/home/headless/contexts
    - report-template-data:/home/headless/qgis-templates
    links:
    - rabbitmq:rabbitmq
    - db:db
    - smtp:smtp
    command:
    - celery
    - -A
    - core.celery_app
    - worker
    - --loglevel=info
    - -Q
    - inasafe-django-indicator
    - -B
    - -n
    - indicator.%h
    labels:
      io.rancher.container.pull_image: always
      cron.schedule: "0 0 * * * ?"
      cron.action: restart

  dbbackup:
    image: kartoza/inasafe-django_dbbackup:v3.4.1
    environment:
      DUMPPREFIX: PG_inasafedjango
      PGDATABASE: ${POSTGRES_DB}
      PGHOST: db
      PGPASSWORD: ${POSTGRES_PASS}
      PGPORT: '5432'
      PGUSER: ${POSTGRES_USER}
    volumes:
    - django-postgis-dbbackup-data:/backups
    - sftpbackup-postgis-target-data:/pg_backup
    links:
    - db:db

  uwsgi:
    image: kartoza/inasafe-django_uwsgi:develop_v4
    environment:
      BROKER_URL: amqp://guest:guest@rabbitmq:5672/
      C_FORCE_ROOT: 'true'
      DATABASE_HOST: db
      DATABASE_NAME: ${POSTGRES_DB}
      DATABASE_PASSWORD: ${POSTGRES_PASS}
      DATABASE_USERNAME: ${POSTGRES_USER}
      DJANGO_SETTINGS_MODULE: core.settings.prod_docker
      INASAFE_REALTIME_BROKER_URL: amqp://guest:guest@rabbitmq:5672/
      INASAFE_HEADLESS_BROKER_URL: amqp://guest:guest@rabbitmq:5672/
      INASAFE_OUTPUT_DIR: /home/headless/outputs
      INAWARE_HOST: ${INAWARE_HOST}
      INAWARE_PASS: ${INAWARE_PASS}
      INAWARE_USER: ${INAWARE_USER}
      LOGGING_DEFAULT_HANDLER: logfile
      LOGGING_DEFAULT_LOG_LEVEL: ERROR
      LOGGING_MAIL_ADMINS: 'False'
      LOGGING_SENTRY: 'False'
      MAPQUEST_MAP_KEY: ''
      PYTHONPATH: /home/web/django_project
      SECRET_KEY: +pf&)&(+gqk+w)1szqvqd33=$$&dd4+t$$34+2ka=ct1zas5ddv%
      SITE_DOMAIN_NAME: ${SITE_DOMAIN_NAME}
    volumes:
    - django-static-data:/home/web/static
    - django-media-data:/home/web/media
    - django-realtime-indicator:/home/web/django_project/.run
    - hazard-drop-data:/home/realtime/hazard-drop
    - shakemaps-data:/home/realtime/shakemaps
    - shakemaps-corrected-data:/home/realtime/shakemaps-corrected
    - floodmaps-data:/home/realtime/floodmaps
    - ashmaps-data:/home/realtime/ashmaps
    - headless-output-data:/home/headless/outputs
    - analysis-context-data:/home/headless/contexts
    - report-template-data:/home/headless/qgis-templates
    links:
    - rabbitmq:rabbitmq
    - db:db
    - smtp:smtp
    labels:
      io.rancher.container.pull_image: always

  django-worker:
    image: kartoza/inasafe-django_uwsgi:develop_v4
    environment:
      BROKER_URL: amqp://guest:guest@rabbitmq:5672/
      C_FORCE_ROOT: 'true'
      DATABASE_HOST: db
      DATABASE_NAME: ${POSTGRES_DB}
      DATABASE_PASSWORD: ${POSTGRES_PASS}
      DATABASE_USERNAME: ${POSTGRES_USER}
      DJANGO_SETTINGS_MODULE: core.settings.prod_docker
      INASAFE_REALTIME_BROKER_URL: amqp://guest:guest@rabbitmq:5672/
      INASAFE_HEADLESS_BROKER_URL: amqp://guest:guest@rabbitmq:5672/
      INASAFE_OUTPUT_DIR: /home/headless/outputs
      INAWARE_HOST: ${INAWARE_HOST}
      INAWARE_PASS: ${INAWARE_PASS}
      INAWARE_USER: ${INAWARE_USER}
      LOGGING_DEFAULT_HANDLER: console
      LOGGING_DEFAULT_LOG_LEVEL: INFO
      LOGGING_MAIL_ADMINS: 'False'
      LOGGING_SENTRY: 'False'
      MAPQUEST_MAP_KEY: ''
      PYTHONPATH: /home/web/django_project
      SECRET_KEY: +pf&)&(+gqk+w)1szqvqd33=$$&dd4+t$$34+2ka=ct1zas5ddv%
      SITE_DOMAIN_NAME: ${SITE_DOMAIN_NAME}
    working_dir: /home/web/django_project
    volumes:
    - django-static-data:/home/web/static
    - django-media-data:/home/web/media
    - django-realtime-indicator:/home/web/django_project/.run
    - hazard-drop-data:/home/realtime/hazard-drop
    - shakemaps-data:/home/realtime/shakemaps
    - shakemaps-corrected-data:/home/realtime/shakemaps-corrected
    - floodmaps-data:/home/realtime/floodmaps
    - ashmaps-data:/home/realtime/ashmaps
    - headless-output-data:/home/headless/outputs
    - analysis-context-data:/home/headless/contexts
    - report-template-data:/home/headless/qgis-templates
    links:
    - rabbitmq:rabbitmq
    - db:db
    - smtp:smtp
    command:
    - celery
    - -A
    - core.celery_app
    - worker
    - --loglevel=info
    - -Q
    - inasafe-django
    - -n
    - inasafe-django.%h
    labels:
      io.rancher.container.pull_image: always
      cron.schedule: "0 0 * * * ?"
      cron.action: restart

  rabbitmq:
    image: library/rabbitmq
    labels:
      io.rancher.container.pull_image: always

  db:
    image: kartoza/postgis:9.6-2.4
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_PASS: ${POSTGRES_PASS}
      POSTGRES_USER: ${POSTGRES_USER}
      ALLOW_IP_RANGE: ${POSTGRES_HBA_RANGE}
      REPLICATE_FROM: ${REPLICATE_FROM}
      REPLICATE_PORT: ${REPLICATE_PORT}
    labels:
      io.rancher.container.pull_image: always
    volumes:
    - django-postgis-data:/var/lib/postgresql
    - django-postgis-dbbackup-data:/backups

{{- if eq .Values.BMKG_ALLOW_SYNC "true" }}
  bmkg-sync:
    image: kartoza/btsync:rancher
    environment:
      DEVICE: ${SYNC_DEVICE_PREFIX} - Shakemaps BMKG
      SECRET: ${BMKG_SYNC}
      STANDBY_MODE: 'TRUE'
    volumes:
    - shakemaps-data:/web
{{- end}}

{{- if eq .Values.SHAKEMAPS_CORRECTED_ALLOW_SYNC "true" }}
  shakemaps-corrected-sync:
    image: kartoza/btsync:rancher
    environment:
      DEVICE: ${SYNC_DEVICE_PREFIX} - Shakemaps Corrected
      SECRET: ${SHAKEMAPS_CORRECTED_SYNC}
      STANDBY_MODE: 'TRUE'
    volumes:
    - shakemaps-corrected-data:/web
{{- end}}

  sftp:
    image: kartoza/realtime-orchestration_sftp:v3.1
    volumes:
    - sftp-ssh-data:/home/realtime/.ssh
    - sftp-ssh-config-data:/etc/ssh
    - shakemaps-data:/home/realtime/shakemaps
    - shakemaps-corrected-data:/home/realtime/shakemaps-corrected
    ports:
    - ${SHAKEMAP_DROP_EXPOSE_PORT}:22/tcp

  shakemap-monitor:
    image: inasafe/realtime_hazard-processor:latest
    command:
    - /docker-entrypoint.sh
    - prod
    - inasafe-realtime-monitor
    environment:
      ASHMAPS_DIR: /home/realtime/ashmaps
      C_FORCE_ROOT: 'True'
      DISPLAY: ':99'
      FLOODMAPS_DIR: /home/realtime/floodmaps
      GRID_FILE_PATTERN: (?P<shake_id>\d{14})/grid\.xml$$
      INASAFE_LOCALE: id
      INASAFE_REALTIME_BROKER_HOST: amqp://guest:guest@rabbitmq:5672/
      INASAFE_REALTIME_PROJECT: /home/realtime/analysis_data/realtime.qgs
      INASAFE_REALTIME_REST_LOGIN_URL: http://web:8080/realtime/api-auth/login/
      INASAFE_REALTIME_REST_PASSWORD: ${INASAFE_REALTIME_REST_PASSWORD}
      INASAFE_REALTIME_REST_URL: http://web:8080/realtime/api/v1/
      INASAFE_REALTIME_REST_USER: ${INASAFE_REALTIME_REST_USER}
      INASAFE_REALTIME_SHAKEMAP_HOOK_URL: http://web:8080/realtime/api/v1/indicator/notify_shakemap_push
      PYTHONPATH: /usr/share/qgis/python:/usr/share/qgis/python/plugins:/usr/share/qgis/python/plugins/inasafe:/home/app
      SHAKEMAPS_DIR: /home/realtime/shakemaps

{{- if eq .Values.ENABLE_SENTRY "true"}}
      INASAFE_SENTRY: 1
      HOSTNAME_SENTRY: "${SITE_DOMAIN_NAME}"
{{- end}}

    volumes:
    - hazard-drop-data:/home/realtime/hazard-drop
    - shakemaps-data:/home/realtime/shakemaps
    - shakemaps-corrected-data:/home/realtime/shakemaps-corrected
    - floodmaps-data:/home/realtime/floodmaps
    - ashmaps-data:/home/realtime/ashmaps
    links:
    - rabbitmq:rabbitmq
    - sftp:sftp
    labels:
      io.rancher.container.pull_image: always
      cron.schedule: "0 0 * * * ?"
      cron.action: restart

  shakemap-corrected-monitor:
    image: inasafe/realtime_hazard-processor:latest
    command:
    - /docker-entrypoint.sh
    - prod
    - inasafe-realtime-monitor
    environment:
      ASHMAPS_DIR: /home/realtime/ashmaps
      C_FORCE_ROOT: 'True'
      DISPLAY: ':99'
      FLOODMAPS_DIR: /home/realtime/floodmaps
      EQ_GRID_SOURCE_TYPE: corrected
      GRID_FILE_PATTERN: (?P<shake_id>\d{14})([\d_-]*)(/output)?/grid\.xml$$
      INASAFE_LOCALE: id
      INASAFE_REALTIME_BROKER_HOST: amqp://guest:guest@rabbitmq:5672/
      INASAFE_REALTIME_PROJECT: /home/realtime/analysis_data/realtime.qgs
      INASAFE_REALTIME_REST_LOGIN_URL: http://web:8080/realtime/api-auth/login/
      INASAFE_REALTIME_REST_PASSWORD: ${INASAFE_REALTIME_REST_PASSWORD}
      INASAFE_REALTIME_REST_URL: http://web:8080/realtime/api/v1/
      INASAFE_REALTIME_REST_USER: ${INASAFE_REALTIME_REST_USER}
      INASAFE_REALTIME_SHAKEMAP_HOOK_URL: http://web:8080/realtime/api/v1/indicator/notify_shakemap_push
      PYTHONPATH: /usr/share/qgis/python:/usr/share/qgis/python/plugins:/usr/share/qgis/python/plugins/inasafe:/home/app
      SHAKEMAPS_DIR: /home/realtime/shakemaps-corrected

{{- if eq .Values.ENABLE_SENTRY "true"}}
      INASAFE_SENTRY: 1
      HOSTNAME_SENTRY: "${SITE_DOMAIN_NAME}"
{{- end}}

    volumes:
    - hazard-drop-data:/home/realtime/hazard-drop
    - shakemaps-data:/home/realtime/shakemaps
    - shakemaps-corrected-data:/home/realtime/shakemaps-corrected
    - floodmaps-data:/home/realtime/floodmaps
    - ashmaps-data:/home/realtime/ashmaps
    links:
    - rabbitmq:rabbitmq
    - sftp:sftp
    labels:
      io.rancher.container.pull_image: always
      cron.schedule: "0 0 * * * ?"
      cron.action: restart

  realtime-worker:
    image: inasafe/realtime_hazard-processor:latest
    command:
    - /docker-entrypoint.sh
    - prod
    - inasafe-realtime-worker
    environment:
      ASHMAPS_DIR: /home/realtime/ashmaps
      C_FORCE_ROOT: 'True'
      DISPLAY: ':99'
      FLOODMAPS_DIR: /home/realtime/floodmaps
      GRID_FILE_PATTERN: (?P<shake_id>\d{14})/grid\.xml$$
      INASAFE_LOCALE: id
      INASAFE_REALTIME_BROKER_HOST: amqp://guest:guest@rabbitmq:5672/
      INASAFE_REALTIME_PROJECT: /home/realtime/analysis_data/realtime.qgs
      INASAFE_REALTIME_REST_LOGIN_URL: http://web:8080/realtime/api-auth/login/
      INASAFE_REALTIME_REST_PASSWORD: ${INASAFE_REALTIME_REST_PASSWORD}
      INASAFE_REALTIME_REST_URL: http://web:8080/realtime/api/v1/
      INASAFE_REALTIME_REST_USER: ${INASAFE_REALTIME_REST_USER}
      INASAFE_REALTIME_SHAKEMAP_HOOK_URL: http://web:8080/realtime/api/v1/indicator/notify_shakemap_push
      PYTHONPATH: /usr/share/qgis/python:/usr/share/qgis/python/plugins:/usr/share/qgis/python/plugins/inasafe:/home/app
      SHAKEMAPS_DIR: /home/realtime/shakemaps

{{- if eq .Values.ENABLE_SENTRY "true"}}
      INASAFE_SENTRY: 1
      HOSTNAME_SENTRY: "${SITE_DOMAIN_NAME}"
{{- end}}

    volumes:
    - hazard-drop-data:/home/realtime/hazard-drop
    - shakemaps-data:/home/realtime/shakemaps
    - shakemaps-corrected-data:/home/realtime/shakemaps-corrected
    - floodmaps-data:/home/realtime/floodmaps
    - ashmaps-data:/home/realtime/ashmaps
    links:
    - rabbitmq:rabbitmq
    - sftp:sftp
    labels:
      io.rancher.container.pull_image: always
      cron.schedule: "0 0 * * * ?"
      cron.action: restart

  analysis-context-data-sync:
    image: kartoza/btsync:rancher
    environment:
      DEVICE: ${SYNC_DEVICE_PREFIX} - Analysis Contexts Data
      SECRET: ${ANALYSIS_CONTEXT_SYNC}
      STANDBY_MODE: 'TRUE'
    volumes:
    - analysis-context-data:/web

  report-template-sync:
    image: alpine/git
    entrypoint: /bin/sh
    working_dir: /web
    command:
      - -c
      - "git pull origin master && git log HEAD^..HEAD && tail -f /dev/null"
    environment:
      DEVICE: ${SYNC_DEVICE_PREFIX} - Report Template
      SECRET: ${REPORT_TEMPLATE_SYNC}
      STANDBY_MODE: 'TRUE'
    volumes:
    - report-template-data:/web
    labels:
      cron.schedule: "*/5 * * * * ?"
      cron.action: restart

  headless-worker:
    image: inasafe/headless_processor:latest
    command:
    - /docker-entrypoint.sh
    - prod
    - inasafe-headless-worker
    links:
    - rabbitmq:rabbitmq
    - analysis-context-data-sync:analysis-context-data-sync
    - report-template-sync:report-template-sync
    volumes:
    - headless-output-data:/home/headless/outputs
    - analysis-context-data:/home/headless/contexts
    - report-template-data:/home/headless/qgis-templates
    - hazard-drop-data:/home/realtime/hazard-drop
    - shakemaps-data:/home/realtime/shakemaps
    - shakemaps-corrected-data:/home/realtime/shakemaps-corrected
    - floodmaps-data:/home/realtime/floodmaps
    - ashmaps-data:/home/realtime/ashmaps
    environment:
      PYTHONPATH: /usr/share/qgis/python:/usr/share/qgis/python/plugins:/usr/share/qgis/python/plugins/inasafe:/home/app
      DISPLAY: ':99'
      C_FORCE_ROOT: 'True'
      INASAFE_LOCALE: id
      INASAFE_HEADLESS_BROKER_HOST: amqp://guest:guest@rabbitmq:5672/
      INASAFE_WORK_DIR: /home/headless
      INASAFE_OUTPUT_DIR: /home/headless/outputs

{{- if eq .Values.ENABLE_SENTRY "true"}}
      INASAFE_SENTRY: 1
      HOSTNAME_SENTRY: "${SITE_DOMAIN_NAME}"
{{- end}}

    labels:
      io.rancher.container.pull_image: always
      cron.schedule: "0 0 * * * ?"
      cron.action: restart
