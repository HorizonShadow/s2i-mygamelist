# horizonshadow/s2i-mygamelist
FROM openshift/base-centos7

# TODO: Put the maintainer name in the image metadata
# LABEL maintainer="Your Name <your@email.com>"

# TODO: Rename the builder environment variable to inform users about application you provide them
# ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
#LABEL io.k8s.description="Platform for building xyz" \
#      io.k8s.display-name="builder x.y.z" \
#      io.openshift.expose-services="8080:http" \
#      io.openshift.tags="builder,x.y.z,etc."

# TODO: Install required packages here:
# RUN yum install -y ... && yum clean all -y

ARG FA_KEY=""
ENV RBENV_ROOT="/opt/app-root/.rbenv"
ENV NVM_DIR="/opt/app-root/.nvm"
RUN yum install -y git-core zlib zlib-devel gcc-c++ patch readline readline-devel \
    libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake  \
    libtool bison curl sqlite-devel \
    && yum clean all -y

RUN cd
RUN git clone git://github.com/sstephenson/rbenv.git /opt/app-root/.rbenv
ENV PATH="/opt/app-root/.rbenv/bin:${PATH}"
ENV PATH="/opt/app-root/.rbenv/versions/2.5.3/bin:${PATH}"
RUN echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
RUN exec $SHELL

RUN git clone git://github.com/sstephenson/ruby-build.git /opt/app-root/.rbenv/plugins/ruby-build
ENV PATH="/opt/app-root/.rbenv/plugins/ruby-build/bin:${PATH}"
RUN exec $SHELL
RUN rbenv install 2.5.3
RUN rbenv global 2.5.3
RUN gem install bundler --no-rdoc --no-ri
RUN gem update --system

run mkdir /opt/app-root/.nvm
run curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
run \. /opt/app-root/.nvm/nvm.sh && nvm install 11.9 
RUN echo "11.9" > /opt/app-root/.nvmrc
ENV PATH="/opt/app-root/.nvm/versions/node/v11.9.0/bin:${PATH}"

run npm install -g yarn
run npm config set "@fortawesome:registry" https://npm.fontawesome.com/ \
    && npm config set "//npm.fontawesome.com/:_authToken" $FA_KEY

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root && chmod -R ug+rwx /opt/app-root

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
