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
	self halt .
 	loader repositories do: [ : rep |  ]. 
	
]

{ #category : #decoration }
SPJavaExperiment >> prepare [

	loader := SPGitLoader new loadAllRepositoriesFor:
		          'stars:>=3000+mirror:false+archived:false+language:java'
]
