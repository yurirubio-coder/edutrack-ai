// Recupera a lista de endereços vinculada ao usuário autenticado.
// Retorna a lista de endereços encontrada.
// Este endpoint não requer parâmetros de entrada, pois utiliza o ID do usuário autenticado.
query meusEnderecos verb=GET {
  api_group = "Endereços"
  auth = "user"

  input {
  }

  stack {
    // Busca o registro do cliente associado ao usuário logado ($auth.id).
    db.get cliente {
      field_name = "user_id"
      field_value = $auth.id
    } as $CLIENTE
  
    // Se o perfil de cliente não existir, retorna uma lista vazia.
    conditional {
      if ($CLIENTE == null) {
        return {
          value = []
        }
      }
    }
  
    // Consulta todos os endereços vinculados ao ID do cliente encontrado.
    // Inclui um join com a tabela 'cep' para trazer informações detalhadas como cidade e estado.
    db.query endereco {
      where = $db.endereco.cliente_id == $CLIENTE.id
      return = {type: "list"}
    } as $ENDERECOS
  }

  response = $ENDERECOS
  guid = "d0zFgArQ08A6giE2Y0Y80hqyJwY"
}