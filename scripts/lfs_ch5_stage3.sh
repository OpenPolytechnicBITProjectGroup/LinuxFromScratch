#!/bin/bash
#Auto compiler for stage 3
bash tclcore_s3.sh
bash expect_s3.sh
bash dejagnu_s3.sh
bash check_s3.sh

