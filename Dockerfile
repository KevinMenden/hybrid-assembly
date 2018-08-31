FROM continuumio/miniconda
MAINTAINER Kevin Menden <kevin.menden@t-online.de>
LABEL authors="kevin.menden@t-online.de" \
    description="Docker image containing all requirements for hybrid-assembly pipeline"

# Create assembly-env
COPY environment_reduced.yml /
RUN conda env create -f /environment_reduced.yml && conda clean -a
ENV PATH /opt/conda/envs/assembly-env/bin:$PATH

# Install MaSuRCA 3.2.8
RUN apt-get update && apt-get install -y g++ libboost-all-dev zlib1g-dev libbz2-dev make
RUN curl -fsSL https://github.com/alekseyzimin/masurca/raw/master/MaSuRCA-3.2.8.tar.gz -o /opt/MaSuRCA-3.2.8.tar.gz
RUN cd /opt/; tar -xzvf MaSuRCA-3.2.8.tar.gz; cd MaSuRCA-3.2.8; ./install.sh
ENV PATH $PATH:/opt/MaSuRCA-3.2.8/bin

# Create NanoQC environment
COPY nanoqc-env.yml /
RUN conda env create -f /nanoqc-env.yml