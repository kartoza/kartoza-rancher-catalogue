version: '2'
volumes:
  django-static-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  django-postgis-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  sftpbackup-media-history-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  django-postgis-dbbackup-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  sftpbackup-postgis-target-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  django-realtime-indicator:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  sftpbackup-postgis-history-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  django-media-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}

  sftp-ssh-config-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  shakemaps-corrected-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  analysis-context-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  hazard-drop-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  ashmaps-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  floodmaps-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  shakemaps-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  sftp-ssh-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}

  report-template-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
{{- end}}
  headless-output-data:
    driver: ${VOLUME_DRIVER}
{{- if eq .Values.RANCHER_SERVER_VERSION "v1.6.12"}}
    driver_opts:
      onRemove: retain
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
      LOGGING_DEFAULT_HANDLER: logfile
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
      cron.schedule: 0 0 * * * ?
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
      LOGGING_DEFAULT_HANDLER: logfile
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
      cron.schedule: 0 0 * * * ?
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
    image: inasafe/realtime_hazard-processor
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
    volumes:
    - hazard-drop-data:/home/realtime/hazard-drop
    - shakemaps-data:/home/realtime/shakemaps
    - floodmaps-data:/home/realtime/floodmaps
    - ashmaps-data:/home/realtime/ashmaps
    links:
    - rabbitmq:rabbitmq
    - sftp:sftp
    labels:
      io.rancher.container.pull_image: always
      cron.schedule: 0 0 * * * ?
      cron.action: restart

  realtime-worker:
    image: inasafe/realtime_hazard-processor
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
    volumes:
    - hazard-drop-data:/home/realtime/hazard-drop
    - shakemaps-data:/home/realtime/shakemaps
    - floodmaps-data:/home/realtime/floodmaps
    - ashmaps-data:/home/realtime/ashmaps
    links:
    - rabbitmq:rabbitmq
    - sftp:sftp
    labels:
      io.rancher.container.pull_image: always
      cron.schedule: 0 0 * * * ?
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
    image: kartoza/btsync:rancher
    environment:
      DEVICE: ${SYNC_DEVICE_PREFIX} - Report Template
      SECRET: ${REPORT_TEMPLATE_SYNC}
      STANDBY_MODE: 'TRUE'
    volumes:
    - report-template-data:/web

  headless-worker:
    image: inasafe/headless_processor
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
    environment:
      PYTHONPATH: /usr/share/qgis/python:/usr/share/qgis/python/plugins:/usr/share/qgis/python/plugins/inasafe:/home/app
      DISPLAY: ':99'
      C_FORCE_ROOT: 'True'
      INASAFE_LOCALE: id
      INASAFE_HEADLESS_BROKER_HOST: amqp://guest:guest@rabbitmq:5672/
      INASAFE_WORK_DIR: /home/headless
      INASAFE_OUTPUT_DIR: /home/headless/outputs