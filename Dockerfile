FROM ubuntu
MAINTAINER Kevin Menden <kevin.menden@t-online.de>
LABEL authors="kevin.menden@t-online.de" \
    description="Docker image containing all requirements for hybrid-assembly pipeline"


ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.4.10-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENV PATH $PATH:/opt/conda/bin
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
COPY environment.yml /
RUN conda env create -f /environment.yml
ENV PATH /opt/conda/envs/assembly-env/bin:$PATH

COPY nanoqc-env.yml /
RUN conda env create -f /nanoqc-env.yml

# Try to install MaSuRCA
RUN apt-get update && apt-get install -y g++ libboost-all-dev zlib1g-dev libbz2-dev make
RUN curl -fsSL https://github.com/alekseyzimin/masurca/files/1668918/MaSuRCA-3.2.4.tar.gz -o /opt/MaSuRCA-3.2.4.tar.gz
RUN cd /opt/; tar -xzvf MaSuRCA-3.2.4.tar.gz; cd MaSuRCA-3.2.4; ./install.sh
ENV PATH $PATH:/opt/MaSuRCA-3.2.4/bin

# For testing
RUN sed -i.bck 's/cnsReuseUnitigs=1" > runCA.spec/cnsReuseUnitigs=1\ndoFragmentCorrection=0" > runCA.spec/' /opt/MaSuRCA-3.2.4/bin/mega_reads_assemble_*.sh
