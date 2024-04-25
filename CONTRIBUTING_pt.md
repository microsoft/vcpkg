# Diretrizes de Contribuição

Vcpkg é um esforço da comunidade para construir um ecossistema produtivo e robusto de bibliotecas nativas - suas contribuições são inestimáveis!

## Problemas (issues)

A maneira mais fácil de contribuir é relatando problemas com `vcpkg.exe` ou um pacote existente no [GitHub](https://github.com/Microsoft/vcpkg). Ao relatar um problema com `vcpkg.exe`, certifique-se de indicar claramente:

- A configuração da máquina: "Estou usando a Atualização de Aniversário do Windows 10. Minha máquina está usando a localidade fr-fr. Executei com sucesso o 'instal boost'."
- As etapas para reproduzir: "I run 'vcpkg list'"
- O resultado esperado: "Eu esperava ver 'boost:x86-windows'"
- O resultado real: "Não recebo nenhuma saída" ou "Recebo uma caixa de diálogo de travamento"

Ao relatar um problema com um pacote, certifique-se de indicar claramente:

- A configuração da máquina (como acima)
- Qual pacote e versão você está construindo: "opencv 3.1.0"
- Quaisquer logs de erro relevantes do processo de compilação.

## Pull Requests

Estamos felizes em aceitar solicitações de correções, recursos, novos pacotes e atualizações para pacotes existentes. Para evitar desperdício de tempo, recomendamos abrir um tópico para discutir se o PR que você está pensando em fazer será aceitável. Isso é duplamente verdadeiro para recursos e novos pacotes.

### Diretrizes de novos pacotes

Estamos felizes por você estar interessado em enviar um novo pacote! Aqui estão algumas diretrizes para ajudá-lo a criar um excelente portfile:

- Evite patches funcionais. Os patches devem ser considerados um último recurso para implementar a compatibilidade quando não houver outra maneira.
- Quando os patches não puderem ser evitados, não modifique o comportamento padrão. O ciclo de vida ideal de um patch é ser mesclado no upstream e não ser mais necessário. Tente manter esse objetivo em mente ao decidir como corrigir algo.
- Prefira usar as funções `vcpkg_xyz` em vez de chamadas brutas `execute_command`. Isso facilita a manutenção de longo prazo quando novos recursos (como sinalizadores de compilador personalizados ou geradores) são adicionados.

## Jurídico

Você precisará preencher um Contrato de Licença de Colaborador (CLA) antes que sua solicitação pull possa ser aceita. Este contrato atesta que você está nos concedendo permissão para usar o código-fonte que está enviando e que este trabalho está sendo enviado sob a licença apropriada para que possamos usá-lo.

Você pode concluir o CLA seguindo as etapas em <https://cla.microsoft.com>. Assim que recebermos o CLA assinado, analisaremos a solicitação. Você só precisará fazer isso uma vez.
