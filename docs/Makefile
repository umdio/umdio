all: dependencies docs

docs:
	jekyll build -s src/ -d public/

bower:
	which bower || npm install -g bower
	bower install

dependencies: bower