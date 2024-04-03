#                                                                               
# Commonly used targets (see each target for more information):                 
#   run: Build code.                                                            
                                                                                
SHELL := /usr/bin/env bash                                                      

.PHONY: all                                                                     
all: help                                                                       
                                                                                
.PHONY: help
help:
	@echo "make run"                                      
                                                                                
.PHONY: run
run:
	rm -rf site
	python3 -m mkdocs build
	python3 -m mkdocs serve
