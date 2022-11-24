Class {
	#name : #SPJavaExperiment,
	#superclass : #SPExperiment,
	#instVars : [
		'loader'
	],
	#category : #Spinoza
}

{ #category : #decoration }
SPJavaExperiment >> extractOntology [

	| amount |
	amount := loader repositories size // 2.
	(loader repositories first: amount) do: [ :rep | 
		self extractor processModel: (self loadProject: rep) ]
]

{ #category : #'as yet unclassified' }
SPJavaExperiment >> loadProject: aFileReference [ 

	^ MOJavaGenericProjectLoader new
		  workingDirectory: aFileReference;
		  loadNamed: aFileReference basename
]

{ #category : #decoration }
SPJavaExperiment >> prepare [

	loader ifNil: [ loader := self prepareFolder ]
]

{ #category : #decoration }
SPJavaExperiment >> prepareFolder [

	^ SPFolderLoader new
		  folder:
			  '/Volumes/Files/SpinozaOntologyExperiment/spinoza'
				  asFileReference;
		  yourself
]

{ #category : #decoration }
SPJavaExperiment >> prepareGit [

	^ SPGitLoader new loadAllRepositoriesFor:
		  'stars:>=3000+mirror:false+archived:false+language:java'
]

{ #category : #running }
SPJavaExperiment >> run [
	self prepare. 
	self extractOntology. 
	self runValidationOnValidCode.
	self runValidationOnInvalidCode.
]
