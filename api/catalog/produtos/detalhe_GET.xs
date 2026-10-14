// Este endpoint retorna os detalhes de um produto específico, incluindo suas personalizações e categorias.
// Retorna os dados do produto.
query "produtos/detalhe" verb=GET {
  api_group = "Catalog"

  input {
    // ID único do produto a ser consultado.
    int produto_id
  }

  stack {
    // Busca o produto pelo ID fornecido.
    db.get produto {
      field_name = "id"
      field_value = $input.produto_id
    } as $produto
  
    // Garante que o produto existe e está ativo.
    precondition ($produto != null && $produto.ativo) {
      error_type = "notfound"
      error = "Produto não encontrado."
    }
  
    // Busca a categoria (tipo) do produto.
    db.get tipo_produto {
      field_name = "id"
      field_value = $produto.tipo_produto_id
    } as $tipo_produto
  
    // Busca todas as personalizações vinculadas a este produto.
    db.query produto_personalizacao {
      where = $db.produto_personalizacao.produto_id == $produto.id
      sort = {ordem_exibicao: "asc", id: "asc"}
      return = {type: "list"}
    } as $personalizacoes
  
    // Lista para agrupar personalizações do tipo checkbox.
    var $personalizacoes_checkbox {
      value = []
    }
  
    // Lista para agrupar personalizações do tipo contador.
    var $personalizacoes_contador {
      value = []
    }
  
    // Lista para agrupar personalizações do tipo radio.
    var $personalizacoes_radio {
      value = []
    }
  
    // Processa cada personalização encontrada se a lista não estiver vazia.
    conditional {
      if (($personalizacoes|count) > 0) {
        foreach ($personalizacoes) {
          each as $personalizacao_item {
            // Busca as opções de escolha para a personalização atual.
            db.query produto_personalizacao_opcao {
              where = $db.produto_personalizacao_opcao.produto_personalizacao_id == $personalizacao_item.id && $db.produto_personalizacao_opcao.ativo == true
              sort = {ordem_exibicao: "asc", id: "asc"}
              return = {type: "list"}
            } as $opcoes
          
            // Processa cada opção para adicionar labels formatados e valores adicionais.
            conditional {
              if (($opcoes|count) > 0) {
                foreach ($opcoes) {
                  each as $opcao_item {
                    // Define o valor adicional, tratando nulos como zero.
                    var $valor_adicional {
                      value = $opcao_item.ajuste_preco ?? 0
                    }
                  
                    // Define o label inicial da opção.
                    var $label_opcao {
                      value = $opcao_item.nome
                    }
                  
                    // Se houver valor adicional, formata o label para exibição.
                    conditional {
                      if ($valor_adicional > 0) {
                        var.update $label_opcao {
                          value = $opcao_item.nome ~ " + R$ " ~ ($valor_adicional|to_text)
                        }
                      }
                    }
                  
                    // Adiciona as novas propriedades ao objeto da opção.
                    var.update $opcao_item {
                      value = $opcao_item
                        |set:"valor_adicional":$valor_adicional
                        |set:"label":$label_opcao
                    }
                  }
                }
              }
            }
          
            // Variável para identificar o nome amigável do tipo de controle.
            var $tipo_controle {
              value = "desconhecido"
            }
          
            // Identifica o tipo de controle baseado no ID (1: checkbox, 2: radio, 3: contador).
            conditional {
              if ($personalizacao_item.produto_personalizacao_tipo_controle_id == 1) {
                var.update $tipo_controle {
                  value = "checkbox"
                }
              }
            
              elseif ($personalizacao_item.produto_personalizacao_tipo_controle_id == 2) {
                var.update $tipo_controle {
                  value = "radio"
                }
              }
            
              elseif ($personalizacao_item.produto_personalizacao_tipo_controle_id == 3) {
                var.update $tipo_controle {
                  value = "contador"
                }
              }
            }
          
            // Atualiza o item de personalização com as opções processadas e o nome do controle.
            var.update $personalizacao_item {
              value = $personalizacao_item
                |set:"tipo_controle":$tipo_controle
                |set:"opcoes":$opcoes
            }
          
            // Distribui a personalização para a lista correspondente ao seu tipo.
            conditional {
              if ($tipo_controle == "checkbox") {
                var.update $personalizacoes_checkbox {
                  value = $personalizacoes_checkbox|push:$personalizacao_item
                }
              }
            
              elseif ($tipo_controle == "contador") {
                var.update $personalizacoes_contador {
                  value = $personalizacoes_contador|push:$personalizacao_item
                }
              }
            
              elseif ($tipo_controle == "radio") {
                var.update $personalizacoes_radio {
                  value = $personalizacoes_radio|push:$personalizacao_item
                }
              }
            }
          }
        }
      }
    }
  
    // Constrói o objeto final do produto com todas as informações agregadas.
    var.update $produto {
      value = $produto
        |set:"tipo_produto":$tipo_produto
        |set:"personalizacoes":$personalizacoes
        |set:"personalizacoes_checkbox":$personalizacoes_checkbox
        |set:"personalizacoes_contador":$personalizacoes_contador
        |set:"personalizacoes_radio":$personalizacoes_radio
    }
  }

  response = $produto
  guid = "NRD_dQfLmFdNRNPzaZSLiUa5AtI"
}