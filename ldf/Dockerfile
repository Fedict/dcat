FROM registry.access.redhat.com/ubi8/ubi-minimal AS builder
RUN microdnf update && microdnf install git-core
RUN cd /tmp && git clone https://github.com/fedict/dcat

FROM registry.access.redhat.com/ubi8/nodejs-16-minimal
USER root
RUN mkdir -p /opt/ldf && chown 1001:0 /opt/ldf
COPY --from=builder /tmp/dcat/ldf/config.json /opt/ldf/config.json
COPY --from=builder /tmp/dcat/all/datagovbe.hdt /opt/ldf/datagovbe.hdt

USER 1001:0
WORKDIR /opt/ldf
RUN npm install @ldf/server 
EXPOSE 5000
CMD ["/opt/ldf/node_modules/@ldf/server/bin/ldf-server", "/opt/ldf/config.json", "5000", "4" ]
