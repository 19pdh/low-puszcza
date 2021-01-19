generate:
	mkdir -p output
	find pages -type f -name '*.cfg' -print0 | sort -zr | xargs -0 saait
	cp style.css print.css output/
	zip -r kronika.zip output
	mv kronika.zip output/kronika.zip

view:
	$(BROWSER) output/index.html

sync:
	rsync -av output/ hiltjo@cow:/home/www/domains/www.codemadness.org/htdocs/
