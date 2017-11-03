#!/bin/bash
#Auto compiler for stage 3
bash tclcore_s3.sh
bash expect_s3.sh
bash dejagnu_s3.sh
bash check_s3.sh
bash ncurses_s3.sh
bash bash_s3.sh
bash bison_s3.sh
bash bzip_s3.sh
bash coreutils_s3.sh
bash diffutils_s3.sh
bash file_s3.sh
bash findutils_s3.sh
bash gawk_s3.sh
bash gettext_s3.sh
bash grep_s3.sh
bash gzip_s3.sh
bash m4_s3.sh
bash make_s3.sh
bash patch_s3.sh
bash perl_s3.sh
bash sed_S3.sh
bash tar_s3.sh
bash texinfo_s3.sh
bash util_linux_s3.sh
bash xz_s3.sh
bash stripping_s3.sh
echo 'You have reached the end of chapter5, backup $LFS/tools directory if desired, and change ownership of /tools directory with "chown -R root:root $LFS/tools"' 
