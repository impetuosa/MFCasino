Class {
	#name : #SPExperiment,
	#superclass : #Object,
	#instVars : [
		'languageName'
	],
	#category : #Spinoza
}

{ #category : #decoration }
SPExperiment >> prepare [
	 self subclassResponsibility.
]
