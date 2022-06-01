Class {
	#name : #SPExperiment,
	#superclass : #Object,
	#instVars : [
		'languageName',
		'extractor'
	],
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPExperiment >> extractor [

	^ extractor ifNil: [ extractor := SPOntologyExtractor new ]
]

{ #category : #decoration }
SPExperiment >> prepare [
	 self subclassResponsibility.
]
