FROM sysdig/sysdig

LABEL maintainer joe@twr.io

ENV SYSDIG_HOST_ROOT /host

ENV HOME /root

COPY sysdig-probe-0.26*.ko /root/.sysdig/

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bash"]
