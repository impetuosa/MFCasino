Class {
	#name : #SPGitLoader,
	#superclass : #Object,
	#instVars : [
		'repositories',
		'loadedRepositories'
	],
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPGitLoader >> cloneAllRepositories [

	| base destination |
	base := 'spinoza' asFileReference ensureCreateDirectory.
	loadedRepositories := repositories collect: [ :rep | 
		                      destination := base / rep first asString.
		                      LibC runCommand:
			                      ('git clone {1} --depth 1 {2} ' format: { 
					                       rep third.
					                       destination fullName }).

		                      rep , { destination } ]
]

{ #category : #'as yet unclassified' }
SPGitLoader >> crawlRepositoriesFor: aQuery [

	| page json response |
	page := 1.
	[ 
	response := ZnEasy get:
		            ('https://api.github.com/search/repositories?q={1}&type=Repositories&page={2}' 
			             format: { 
					             aQuery.
					             page asString }).
	json := STONJSON fromStream: response entity readStream.
	repositories addAll: ((json at: #items) collect: [ :i | 
			 { 
				 (i at: #id).
				 (i at: #full_name).
				 (i at: #clone_url) } ]).
	page := page + 1 ] doWhileTrue: [ (json at: #items) isNotEmpty ]
]

{ #category : #'as yet unclassified' }
SPGitLoader >> loadAllRepositoriesFor: aQuery [

	| response json page |
	repositories := OrderedCollection new.

	self crawlRepositoriesFor: aQuery.
	self cloneAllRepositories
]

{ #category : #accessing }
SPGitLoader >> repositories [

	^ loadedRepositories
]
