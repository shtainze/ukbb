###########
# Usage
# docker build -t shtainze/ukbb .
###########

FROM ubuntu:22.04

# Update apt packages
RUN apt update
RUN apt upgrade -y

# Install software
RUN apt install -y wget curl unzip tabix 

# Install MAGMA
RUN mkdir -p software/magma
RUN wget -q "https://ctg.cncr.nl/software/MAGMA/prog/magma_v1.10.zip" -P software/magma
RUN unzip software/magma/magma_v1.10.zip -d software/magma
ENV PATH $PATH:software/magma

# Install PLINK2
RUN mkdir -p software/plink2
RUN wget -q https://s3.amazonaws.com/plink2-assets/alpha3/plink2_linux_x86_64_20220814.zip -P software/plink2
RUN unzip software/plink2/plink2_linux_x86_64_20220814.zip -d software/plink2
ENV PATH $PATH:software/plink2

# Set default command to /bin/bash
CMD ["/bin/bash"]
