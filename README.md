AntWorld
========

Un mini projet sans ambition qui vis à jouer avec Elixir.


Idée de base
--------------

Les fourmis ont un moyen intéressant pour trouver des la nourriture.
Chaque fourmi à des actions limité. Mais globalement c'Est très efficace.

Une fourmi peut partir à la recherche de nourriture.
Une fourmi peut en tout temps revenir vers sa fournillière.
Une fois qu'une fourmi à trouver une source de nourriture, elle peux laisser une trace en revennant vers la fourmilière.
Les traces laissé par les fourmit s'accumule avec le temps.
Une fourmi en recherche de de nourriture va suivre la piste qui sens le plus fort.

Run?
--------
$ iex -S mix
iex(1)> AntWorld.run

État courrant
-----------------

Pour le moment, on démarre l'appli avec une fourmi dans un monde carré de 1_000 * 1_000.
La fourmi va partir à la recherche de nourriture et revennir rapidement vers la fourmillière quand elle à quelque chose dans son sac.

Il n'y a pas encore de trace, et il n'y a pas encore plusieurs fourmi.

Futur
------------

* Je veux être capable de configurer la quantité de fourmi et la taille de la carte.
* Je veux être capable de controller les différent processus avec OTP.
* Je veux être capable de voir de belle manière ce qui se passe dans le monde. Surement avec un autre process qui redessinera la carte à chaque dessin.
* Je veux que les fourmi puisse laisser des traces de leur passage.
* Je veux être capable de partir des instance de fourmi sur un réseau
