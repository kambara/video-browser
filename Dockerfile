FROM ruby:2.4-onbuild

EXPOSE 8080
CMD ["bundle", "exec", "puma", "-p", "8080"]
