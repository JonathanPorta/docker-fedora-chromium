FROM fedora:26

# Add repo for Node.js and then install packages
RUN curl -sL https://rpm.nodesource.com/setup_8.x | bash - ; \
  curl https://dl.yarnpkg.com/rpm/yarn.repo -o /etc/yum.repos.d/yarn.repo ; \
  dnf install -y gcc-c++ make findutils jq unzip nodejs yarn

ADD ./install-chrome.sh /opt/jonathanporta/

RUN /opt/jonathanporta/install-chrome.sh /opt/

ENV CHROME_PATH /opt/chrome-linux/chrome
