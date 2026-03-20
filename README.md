Golem:
- Faire la gestion du spawn de joueur (preparation au ClientSideModel) (18.03)
		- Setup l'invulnerabilite pour le character creator

- Faire une lib graphique avec une DA preconstruite + Color (VGUIElement) (19.03 + week-end au complet)
		- DFrame
		- DPanel
		- etc...

- Fonctionnalite du ClientSideModel(global)(character/inventaire)
- Character creator etc...

Yuu:
- module admin (1s/2s)
		- gradation (rank) par niveau 0, 1, 2, 3, 4, 5 etc... (le niveau le plus bas sera le plus fort) (un niveau 1 pourra pas toucher et interagir sur le niveau 0 etc... pour tous les niveaux) (server only)
		- refaire toutes les commandes utilitaires (hp, armor, tp, bring, etc...) (server only)
		- Interface UI / UX avec la lib du gamemode (VGUIElement + Responsivite)
		(l'idee c'est de rendre la tache plus simple pour un modo/animateur)(ne pas prevoir d'interface pour le niveau 0)

- sv-ranks
	(sv_utils)
- sv-config
- l'ensemble des commandes(commands/set... get... etc...)



faire que de l'interaction avec F10 et Hook(PlayerSay) pour le moment, pas d'UI
gestion des cas (nil value, bot, error syntaxe, parsing des commandes, logs console avec MsgC(....))

- module logs (3j/4j)
		- simple pas besoin d'extra
		- API/Fonction explortable dans les autres modules
		- Interface UI / UX, simple sans prise de tete
		- Affichage only, aucun delete (read_only)
- module warn (2j/3j)
		- simple pas besoin d'extra
		- Interface UI / UX, simple sans prise de tete
		- Affichage only, aucun delete (read_only)
		(pour le delete on passera pas un ID de reference unique)
		(quand un warn est distibuer stock le dans le WHERE du joueur et aussi une table de global qui enregistre l'ensemble des warn sans distinction)
- config jobs + categories
- config des ranks admin

- Intéresse toi au max sur les Flex et si c'est carre prevoir pour la suite sinon FF