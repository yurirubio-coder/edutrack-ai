// Atualiza o endereço padrão do cliente e retorna a lista de endereços formatada
// Retorna os dados no formato solicitado: { padrao: {}, naoPadrao: [] }
query marcarEnderecoPadrao verb=PATCH {
  api_group = "Endereços"

  input {
    // ID do endereço que será definido como padrão
    int endereco_id
  }

  stack {
    // Busca o endereço para validar existência e obter o cliente_id
    db.get endereco {
      field_name = "id"
      field_value = $input.endereco_id
    } as $endereco_selecionado
  
    // Valida se o endereço existe
    precondition ($endereco_selecionado != null) {
      error_type = "notfound"
      error = "Endereço não encontrado."
    }
  
    db.transaction {
      stack {
        // Busca outros endereços do mesmo cliente que estejam marcados como padrão
        db.query endereco {
          where = $db.endereco.cliente_id == $endereco_selecionado.cliente_id && $db.endereco.padrao == true && $db.endereco.id != $input.endereco_id
          return = {type: "list"}
        } as $outros_padrao
      
        // Remove a marcação de padrão dos outros endereços
        foreach ($outros_padrao) {
          each as $item {
            db.patch endereco {
              field_name = "id"
              field_value = $item.id
              data = {padrao: false}
            } as $res
          }
        }
      
        // Define o endereço selecionado como padrão
        db.patch endereco {
          field_name = "id"
          field_value = $input.endereco_id
          data = {padrao: true}
        } as $padrao_raw
      }
    }
  
    // Busca os demais endereços (não padrão) para compor a resposta
    db.query endereco {
      where = $db.endereco.cliente_id == $endereco_selecionado.cliente_id && $db.endereco.id != $input.endereco_id
      return = {type: "list"}
    } as $nao_padrao_raw
  
    // Formata o endereço padrão removendo o campo bairro
    var $padrao {
      value = {
        id         : $padrao_raw.id
        created_at : $padrao_raw.created_at
        cliente_id : $padrao_raw.cliente_id
        logradouro : $padrao_raw.logradouro
        numero     : $padrao_raw.numero
        complemento: $padrao_raw.complemento
        referencia : $padrao_raw.referencia
        padrao     : $padrao_raw.padrao
        cep_id     : $padrao_raw.cep_id
      }
    }
  
    // Formata a lista de endereços não padrão removendo o campo bairro
    array.map ($nao_padrao_raw) {
      by = {
        id         : $this.id
        created_at : $this.created_at
        cliente_id : $this.cliente_id
        logradouro : $this.logradouro
        numero     : $this.numero
        complemento: $this.complemento
        referencia : $this.referencia
        padrao     : $this.padrao
        cep_id     : $this.cep_id
      }
    } as $nao_padrao
  }

  response = {padrao: $padrao, naoPadrao: $nao_padrao}
  guid = "1_pnw_ehXFeOV-MuawPiEc0xeJo"
}