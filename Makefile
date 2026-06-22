.PHONY: build-base run-week1 run-week2 run-week3 run-week4 run-week5 run-week6 run-week7 run-week8 run-week9 run-week10 run-week11 run-week12 stop-all clean-all down-all build-all

# Build the shared base image
build-base:
	docker build -f base.Dockerfile -t ethical-base .

# Run specific week
run-week1:
	cd labs/week1 && docker compose up -d

run-week2:
	@echo "Week 2: Ethical discussions - no Docker needed. Review README."
	@cat labs/week2/README.md 2>/dev/null || echo "Create README for Week 2 ethics."

run-week3:
	cd labs/week3 && docker compose up -d

run-week4:
	cd labs/week4 && docker compose up -d

run-week5:
	cd labs/week5 && docker compose up -d

run-week6:
	cd labs/week6 && docker compose up -d

run-week7:
	cd labs/week7 && docker compose up -d

run-week8:
	cd labs/week8 && docker compose up -d

run-week9:
	cd labs/week9 && docker compose up -d

run-week10:
	cd labs/week10 && docker compose up -d

run-week11:
	@echo "Week 11: Physical access controls - no Docker needed. Review README."
	@cat labs/week11/README.md 2>/dev/null || echo "Create README for Week 11 physical security."

run-week12:
	@echo "Week 12: Social engineering - no Docker needed. Review README."
	@cat labs/week12/README.md 2>/dev/null || echo "Create README for Week 12 social engineering."

# Build all weeks (if any have Dockerfiles)
build-all:
	$(MAKE) build-base

# Stop all weeks that have compose files
stop-all:
	for week in 1 3 4 5 6 7 8 9 10; do \
		(cd labs/week$$week && docker compose down 2>/dev/null || true); \
	done

# Clean unused images
clean-all:
	docker system prune -f

# Down all
down-all: stop-all clean-all
