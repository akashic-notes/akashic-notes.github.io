Akashic Record System


## Requirements

  * Zero cost for everyday person
  * Minimal friction for publishing using common tools
  * 

## Design

There is a hidden structure to the materials we read.

We have dictionaries for words, and textbooks for subjects, and articles for larger concepts.

### Repository Structure

```
/
	.records/
		<recordID>/
			.automation/
				.onentry
				
			<file>
			
			symlink to record/
				
		...
	
	
	symlink to record/
```

generally directories should not exist except for record metadata dirs

git directory

### Webextension

#### Configuration

Webextension configuration is defined at its record root. e.g.:
```
/web/
	.config/
	
	by-date/
	by-site/
```

#### Messaging


#### Commands

##### Record

Selected text is captured as record.

It is added to contexts configured at webextension root.

##### Send




##### Context


##### Execute


#### Publisher

#### static site generator

input: parts of repo -> outputs: part of static site

#### web view


### Interaction Site

for social
for automation





## Verticals

### Input
afdasdf




## Ideas

#### Viewer

##### Repository viewer
##### Web Layer viewer


## Ideals

### Data Ownership
### Independent Communication
