FROM continuumio/miniconda
MAINTAINER Kevin Menden <kevin.menden@t-online.de>
LABEL authors="kevin.menden@t-online.de" \
    description="Docker image containing all requirements for hybrid-assembly pipeline"

COPY environment.yml /
RUN conda env create -f /environment.yml
ENV PATH /opt/conda/envs/nfcore-methylseq/bin:$PATH
