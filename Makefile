#TODO remove compiled files from repo and readd comp TS when py TC merged
# configurable variables 
SERVICE = narrativejobproxy
SERVICE_NAME = narrativejobproxy
SERVICE_NAME_PY = narrativejobproxy
#SERVICE_PSGI_FILE = $(SERVICE_NAME).psgi
KB_SERVICE_NAME = narrativejobproxy
SERVICE_PORT = 7068
URL = http://localhost:$(SERVICE_PORT)

#uwsgi variables
MAX_PROCESSES = 20
MIN_PROCESSES = 4
GEVENT_PROCESSES = 5

#standalone variables which are replaced when run via /kb/dev_container/Makefile
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment

#include $(TOP_DIR)/tools/Makefile.common.rules
SERVICE_DIR ?= $(TARGET)/services/$(SERVICE_NAME)
PID_FILE = $(SERVICE_DIR)/service.pid
LOG_FILE = $(SERVICE_DIR)/log/uwsgi.log

# make sure our make test works
.PHONY : test

# default target is all, which compiles the typespec and builds documentation
default: all

all: build-libs build-docs

build-libs:

compile-typespec:
	mkdir -p lib/biokbase/$(SERVICE_NAME_PY)
	touch lib/biokbase/__init__.py #do not include code in biokbase/__init__.py
	touch lib/biokbase/$(SERVICE_NAME_PY)/__init__.py 
	mkdir -p lib/javascript/$(SERVICE_NAME)
	compile_typespec \
		--pyserver biokbase.$(SERVICE_NAME_PY).server \
		--pyimpl biokbase.$(SERVICE_NAME_PY).impl \
		--client Bio::KBase::$(SERVICE_NAME_PY)::Client \
		--py biokbase/$(SERVICE_NAME_PY)/client \
		--js javascript/$(SERVICE_NAME)/Client \
		--service $(SERVICE_NAME)Server \
		--impl $(SERVICE_NAME)Impl \
		--url $(URL) \
		$(SERVICE_NAME).spec lib
	-rm lib/$(SERVICE_NAME)Server.pm
	-rm lib/$(SERVICE_NAME)Impl.pm
	-rm -r biokbase

build-docs: build-libs
	mkdir -p docs
	pod2html --infile=lib/Bio/KBase/$(SERVICE_NAME)/Client.pm --outfile=docs/$(SERVICE_NAME).html
	rm -f pod2htmd.tmp

# here are the standard KBase test targets (test, deploy-client, deploy-scripts, & deploy-service)

test:
	@echo "no tests, workaround service

test-client:
	@echo "no tests, workaround service

test-scripts:
	@echo "no tests, workaround service

test-service:
	@echo "no tests, workaround service

#include $(TOP_DIR)/tools/Makefile.common.rules

# here are the standard KBase deployment targets (deploy,deploy-client, deploy-scripts, & deploy-service)

deploy: deploy-client deploy-service
	echo "OK... Done deploying ALL artifacts (includes clients, docs, scripts and service) of $(SERVICE_NAME)."

deploy-client: deploy-libs deploy-docs

deploy-libs:
	mkdir -p $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)
	mkdir -p $(TARGET)/lib/biokbase/$(SERVICE_NAME_PY)
	mkdir -p $(TARGET)/lib/javascript/$(SERVICE_NAME)
	cp lib/Bio/KBase/$(SERVICE_NAME)/Client.pm $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)/.
	cp lib/biokbase/$(SERVICE_NAME_PY)/client.py $(TARGET)/lib/biokbase/$(SERVICE_NAME_PY)/.
	cp lib/biokbase/$(SERVICE_NAME_PY)/__init__.py $(TARGET)/lib/biokbase/$(SERVICE_NAME_PY)/.
	touch $(TARGET)/lib/biokbase/__init__.py
	cp lib/javascript/$(SERVICE_NAME)/* $(TARGET)/lib/javascript/$(SERVICE_NAME)/.
	echo "deployed clients of $(SERVICE_NAME)."
	
deploy-docs:
	mkdir -p $(SERVICE_DIR)/webroot
	cp docs/*.html $(SERVICE_DIR)/webroot/.

# deploys all libraries and scripts needed to start the service

deploy-service: deploy-service-libs deploy-service-scripts

deploy-service-libs:
	mkdir -p $(TARGET)/lib/biokbase/$(SERVICE_NAME_PY)
	touch $(TARGET)/lib/biokbase/__init__.py
	rsync -arv lib/biokbase/$(SERVICE_NAME_PY)/* $(TARGET)/lib/biokbase/$(SERVICE_NAME_PY)/.
	mkdir -p $(SERVICE_DIR)
	echo "deployed service for $(SERVICE_NAME)."

# creates start/stop/reboot scripts and copies them to the deployment target
deploy-service-scripts:
	
	#NOTE: uses gevent. You must have gevent_monkeypatch_all=1 in your deploy.cfg file for this to work
	
	# Create the start script (should be a better way to do this...)
	echo '#!/bin/sh' > ./start_service
	echo "echo starting $(SERVICE_NAME) service." >> ./start_service
	echo 'export PYTHONPATH=$(TARGET)/lib:$$PYTHONPATH' >> ./start_service
	echo 'if [ -z "$$KB_DEPLOYMENT_CONFIG" ]' >> ./start_service
	echo 'then' >> ./start_service
	echo '    export KB_DEPLOYMENT_CONFIG=$(TARGET)/deployment.cfg' >> ./start_service
	echo 'fi' >> ./start_service
	echo 'export KB_SERVICE_NAME=$(KB_SERVICE_NAME)' >> ./start_service
	echo "uwsgi --master --processes $(MAX_PROCESSES) --cheaper $(MIN_PROCESSES) --gevent $(GEVENT_PROCESSES) \\" >> ./start_service
	echo "    --http :$(SERVICE_PORT) --http-timeout 600 --pidfile $(PID_FILE) --daemonize $(LOG_FILE) \\" >> ./start_service
	echo "    --wsgi-file $(TARGET)/lib/biokbase/$(SERVICE_NAME_PY)/server.py" >> ./start_service
	echo "echo $(SERVICE_NAME) service is listening on port $(SERVICE_PORT).\n" >> ./start_service
	
	# Create a debug start script that is not daemonized
	echo '#!/bin/sh' > ./debug_start_service
	echo 'export PYTHONPATH=$(TARGET)/lib:$$PYTHONPATH' >> ./debug_start_service
	echo 'if [ -z "$$KB_DEPLOYMENT_CONFIG" ]' >> ./debug_start_service
	echo 'then' >> ./debug_start_service
	echo '    export KB_DEPLOYMENT_CONFIG=$(TARGET)/deployment.cfg' >> ./debug_start_service
	echo 'fi' >> ./debug_start_service
	echo 'export KB_SERVICE_NAME=$(KB_SERVICE_NAME)' >> ./debug_start_service
	echo "uwsgi --http :$(SERVICE_PORT) --http-timeout 600 --gevent $(GEVENT_PROCESSES)  \\" >> ./debug_start_service
	echo "    --wsgi-file $(TARGET)/lib/biokbase/$(SERVICE_NAME_PY)/server.py" >> ./debug_start_service
	
	# Create the stop script (should be a better way to do this...)
	echo '#!/bin/sh' > ./stop_service
	echo "echo trying to stop $(SERVICE_NAME) service." >> ./stop_service
	echo "if [ ! -f $(PID_FILE) ] ; then " >> ./stop_service
	echo "\techo \"No pid file: $(PID_FILE) found for service $(SERVICE_NAME).\"\n\texit 1\nfi" >> ./stop_service
	echo "uwsgi --stop $(PID_FILE)\n" >> ./stop_service
	
	# Create a script to reboot the service by redeploying the service and reloading code
	echo '#!/bin/sh' > ./reboot_service
	echo '# auto-generated script to stop the service, redeploy service implementation, and start the servce' >> ./reboot_service
	echo "if [ ! -f $(PID_FILE) ] ; then " >> ./reboot_service
	echo "\techo \"No pid file: \$(PID_FILE) found for service $(SERVICE_NAME).\"\n\texit 1\nfi" >> ./reboot_service
	echo "cd $(ROOT_DEV_MODULE_DIR)\nmake deploy-service-libs\ncd -\nuwsgi --reload $(PID_FILE)" >> ./reboot_service
	
	# Actually run the deployment of these scripts
	chmod +x start_service stop_service reboot_service debug_start_service
	mkdir -p $(SERVICE_DIR)
	mkdir -p $(SERVICE_DIR)/log
	cp start_service $(SERVICE_DIR)/
	cp debug_start_service $(SERVICE_DIR)/
	cp stop_service $(SERVICE_DIR)/
	cp reboot_service $(SERVICE_DIR)/

undeploy:
	rm -rfv $(SERVICE_DIR)
	rm -rfv $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)
	#rm -rfv $(TARGET)/lib/$(SERVICE_PSGI_FILE)
	rm -rfv $(TARGET)/lib/biokbase/$(SERVICE_NAME_PY)
	rm -rfv $(TARGET)/lib/javascript/$(SERVICE_NAME)
	#rm -rfv $(TARGET)/docs/$(SERVICE_NAME)
	echo "OK ... Removed all deployed files."

# remove files generated by building the service
clean:
	rm -rf lib/Bio/KBase/$(SERVICE_NAME)
	rm -f lib/biokbase/$(SERVICE_NAME_PY)/client.pm
	rm -f lib/biokbase/$(SERVICE_NAME_PY)/server.pm
	#rm -f lib/Bio/KBase/$(SERVICE_NAME)/Service.pm
	#rm -f lib/$(SERVICE_PSGI_FILE)
	rm -rf lib/javascript
	rm -rf docs
	rm -f start_service stop_service reboot_service debug_start_service
