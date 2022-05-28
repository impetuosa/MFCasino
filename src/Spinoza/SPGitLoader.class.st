Class {
	#name : #SPGitLoader,
	#superclass : #Object,
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPGitLoader >> loadAllRepositoriesFor: aQuery [
		self halt .
'https://api.github.com/search/repositories?q={1}&type=Repositories' format: { aQuery }.
]
