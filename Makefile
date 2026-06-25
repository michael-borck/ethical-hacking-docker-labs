.PHONY: build-base build-all run-week1 run-week2 run-week3 run-week4 run-week5 run-week6 run-week7 run-week8 run-week9 run-week10 run-week11 run-week12 stop-all clean-all down-all status

# Build the shared base image (required once before any hands-on lab)
build-base:
	docker build -f base.Dockerfile -t ethical-base .

# Shared recipe: start a week's compose if present, otherwise print a clear message.
# Looks for either docker-compose.yml or docker-compose.yaml so it works for every week.
define WEEK_RECIPE
	@week=$(1); \
	if [ -f "labs/week$$week/docker-compose.yml" ] || [ -f "labs/week$$week/docker-compose.yaml" ]; then \
		echo "==> Starting week $$week"; \
		(cd labs/week$$week && docker compose up -d); \
	elif [ "$$week" = "2" ]; then \
		echo "==> Week 2 is docs-only (ethics & law). Open labs/week2/README.md and complete the discussion guide."; \
	else \
		echo "==> Week $$week: no compose file found. See labs/week$$week/README.md if it exists."; \
	fi
endef

run-week1:
	$(call WEEK_RECIPE,1)
run-week2:
	$(call WEEK_RECIPE,2)
run-week3:
	$(call WEEK_RECIPE,3)
run-week4:
	$(call WEEK_RECIPE,4)
run-week5:
	$(call WEEK_RECIPE,5)
run-week6:
	$(call WEEK_RECIPE,6)
run-week7:
	$(call WEEK_RECIPE,7)
run-week8:
	$(call WEEK_RECIPE,8)
run-week9:
	$(call WEEK_RECIPE,9)
run-week10:
	$(call WEEK_RECIPE,10)
run-week11:
	$(call WEEK_RECIPE,11)
run-week12:
	$(call WEEK_RECIPE,12)

# Build base, then build any per-week images that declare a Dockerfile
build-all:
	$(MAKE) build-base
	@for week in $$(seq 1 12); do \
		if [ -f "labs/week$$week/Dockerfile" ]; then \
			echo "==> Building labs/week$$week"; \
			(cd labs/week$$week && docker compose build); \
		fi; \
	done

# Stop every week (silently skips weeks with no compose file)
stop-all:
	@for week in $$(seq 1 12); do \
		if [ -f "labs/week$$week/docker-compose.yml" ] || [ -f "labs/week$$week/docker-compose.yaml" ]; then \
			echo "==> Stopping week $$week"; \
			(cd labs/week$$week && docker compose down 2>/dev/null || true); \
		fi; \
	done

# Show which weeks are available
status:
	@echo "Ethical Hacking Labs — availability:"; \
	for week in $$(seq 1 12); do \
		if [ -f "labs/week$$week/docker-compose.yml" ] || [ -f "labs/week$$week/docker-compose.yaml" ]; then \
			echo "  week$$week: ready (make run-week$$week)"; \
		elif [ -d "labs/week$$week" ]; then \
			echo "  week$$week: docs only (see labs/week$$week/README.md)"; \
		else \
			echo "  week$$week: not built"; \
		fi; \
	done

# Clean unused images
clean-all:
	docker system prune -f

# Down all + clean
down-all: stop-all clean-all
