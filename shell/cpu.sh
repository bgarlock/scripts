#!/bin/bash

top -l 1| awk 'CPU usage {print $6, $7, $8, $9, $10, $11, $12, $13}'
