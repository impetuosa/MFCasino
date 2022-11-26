Class {
	#name : #SPFolderLoader,
	#superclass : #Object,
	#instVars : [
		'folder',
		'repositories'
	],
	#category : #Spinoza
}

{ #category : #accessing }
SPFolderLoader >> folder: aFileReference [ 
	folder := aFileReference
]

{ #category : #accessing }
SPFolderLoader >> repositories [

	^ repositories ifNil: [ 
		  repositories := folder directories collect: [ :d | 
			                  d asFileReference ] ]
]
