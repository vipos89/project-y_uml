# Modern Makefile for PlantUML conversion
SHELL := /bin/bash
PLANTUML_JAR := plantuml.jar
GRAPHVIZ_DOT := $(shell command -v dot 2>/dev/null)
DIAGRAMS_DIR := diagrams
OUTPUT_FORMATS := png svg

# Check dependencies
ifeq (, $(GRAPHVIZ_DOT))
$(error "Graphviz/dot not found. Install with: brew install graphviz")
endif

ifeq (, $(wildcard $(PLANTUML_JAR)))
$(info "Downloading plantuml.jar...")
$(shell curl -L -o $(PLANTUML_JAR) "https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar" 2>/dev/null)
endif

# Find all diagram files
DIAGRAM_FILES := $(shell find $(DIAGRAMS_DIR) -type f \( -name '*.puml' -o -name '*.plantuml' \) 2>/dev/null)

# Conversion targets
.PHONY: all clean convert-png convert-svg

all: convert-png convert-svg

convert-png: $(addsuffix .png,$(basename $(DIAGRAM_FILES)))
convert-svg: $(addsuffix .svg,$(basename $(DIAGRAM_FILES)))

# Pattern rule for PNG conversion
%.png: %.puml $(PLANTUML_JAR)
	@mkdir -p "$(dir $<)generated"
	@echo "Converting $< to PNG"
	-@java -Djava.awt.headless=true -jar $(PLANTUML_JAR) -tpng -nometadata -graphvizdot "$(GRAPHVIZ_DOT)" "$<" -o "$(abspath $(dir $<)generated)" || echo "Error converting $< to PNG, continuing..."

%.png: %.plantuml $(PLANTUML_JAR)
	@mkdir -p "$(dir $<)generated"
	@echo "Converting $< to PNG"
	-@java -Djava.awt.headless=true -jar $(PLANTUML_JAR) -tpng -nometadata -graphvizdot "$(GRAPHVIZ_DOT)" "$<" -o "$(abspath $(dir $<)generated)" || echo "Error converting $< to PNG, continuing..."

# Pattern rule for SVG conversion
%.svg: %.puml $(PLANTUML_JAR)
	@mkdir -p "$(dir $<)generated"
	@echo "Converting $< to SVG"
	-@java -Djava.awt.headless=true -jar $(PLANTUML_JAR) -tsvg -graphvizdot "$(GRAPHVIZ_DOT)" "$<" -o "$(abspath $(dir $<)generated)" || echo "Error converting $< to SVG, continuing..."

%.svg: %.plantuml $(PLANTUML_JAR)
	@mkdir -p "$(dir $<)generated"
	@echo "Converting $< to SVG"
	-@java -Djava.awt.headless=true -jar $(PLANTUML_JAR) -tsvg -graphvizdot "$(GRAPHVIZ_DOT)" "$<" -o "$(abspath $(dir $<)generated)" || echo "Error converting $< to SVG, continuing..."

clean:
	@echo "Cleaning generated files..."
	@find $(DIAGRAMS_DIR) -type d -name "generated" -exec rm -rf {} +
	@echo "Clean complete"

info:
	@echo "Found diagram files:"
	@echo $(DIAGRAM_FILES) | tr ' ' '\n'