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
		self extractor extractFromModel: (self loadProject: rep) ]
]

{ #category : #'as yet unclassified' }
SPJavaExperiment >> loadProject: rep [

	^ MOJavaGenericProjectLoader new
		  workingDirectory: rep fourth;
		  loadNamed: rep second
]

{ #category : #decoration }
SPJavaExperiment >> prepare [

	loader ifNil: [ 
		loader := SPGitLoader new loadAllRepositoriesFor:
			          'stars:>=3000+mirror:false+archived:false+language:java' ]
]

{ #category : #running }
SPJavaExperiment >> run [
	self prepare. 
	self extractOntology. 
	self runValidationOnValidCode.
	self runValidationOnInvalidCode.
]
