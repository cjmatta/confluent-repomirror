FROM centos:centos7

ARG CONFLUENT_VERSION

RUN echo "===> clean yum caches ....." \
    && yum clean all

RUN echo "===> Installing curl wget netcat python...." \
    && yum install -y \
								yum-utils \
								createrepo \
                curl \
                git \
                wget \
                nc \
                python
RUN echo "===> Adding confluent repository... https://packages.confluent.io/rpm/${CONFLUENT_VERSION}/7"
RUN rpm --import https://packages.confluent.io/rpm/${CONFLUENT_VERSION}/archive.key
RUN bash -c 'echo -e "[Confluent.dist]\n\
name=Confluent repository (dist)\n\
baseurl= https://packages.confluent.io/rpm/${CONFLUENT_VERSION}/7\n\
gpgcheck=1\n\
gpgkey=https://packages.confluent.io/rpm/${CONFLUENT_VERSION}/archive.key\n\
enabled=1\n\
\n\
[Confluent] \n\
name=Confluent repository \n\
baseurl= https://packages.confluent.io/rpm/${CONFLUENT_VERSION}\n\
gpgcheck=1 \n\
gpgkey=https://packages.confluent.io/rpm/${CONFLUENT_VERSION}/archive.key\n\
enabled=1 " > /etc/yum.repos.d/confluent.repo';

RUN yum clean all
RUN mkdir /repodir
WORKDIR /repodir

CMD ["reposync", "-r", "Confluent.dist", "&&", "reposync", "-r", "Confluent"]