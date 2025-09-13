#!/usr/bin/env bash
TARGET=$1  # e.g., http://34.12.34.56:3000
docker run --rm -v $(pwd):/zap/wrk/:rw owasp/zap2docker-stable zap-baseline.py -t $TARGET -r zap-baseline-report.html -j zap-baseline-report.json
