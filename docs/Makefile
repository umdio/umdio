all: dependencies docs

docs:
	jekyll build

run:
	jekyll serve

bower:
	which bower || npm install -g bower
	bower install

dependencies: bower
