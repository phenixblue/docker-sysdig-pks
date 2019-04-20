FROM sysdig/sysdig

LABEL maintainer joe@twr.io

ENV SYSDIG_HOST_ROOT /host

ENV HOME /root

COPY sysdig-probe-0.24.2-x86_64-4.15.0-42-generic-751ae282dd3b11ba9ea4d659a9e2ffc8.ko /root/.sysdig/

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bash"]