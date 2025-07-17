# Azure Policys automatisieren

In fast jedem Projekt: Irgendwer erstellt VMs in Regionen, die keiner braucht.

Oder in Größen, die keiner zahlen will.

Mit Azure Policy und Terraform kannst du Regeln aufstellen, die automatisch greifen:

- Nur bestimmte VM-Typen.

- Nur bestimmte Regionen.

- Und bitte immer mit Tags.

Das nimmt Diskussionen raus, weil der Code oder die Policy, die Regeln durchsetzt.

Nicht du.

Terraform integriert das als Ressource azurerm_policy_definition.

Beispiel einer Policy, für die Einschränkung der Azure Region auf West Europe (Niederlande, Amsterdam).
