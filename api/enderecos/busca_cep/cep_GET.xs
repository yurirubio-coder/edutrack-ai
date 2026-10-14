// Retorna a lista formatada
// Entrada do CEP para busca
query "buscaCEP/{cep}" verb=GET {
  api_group = "Endereços"

  input {
    text cep filters=trim
  }

  stack {
    // Mapeamento de UF para Nome do Estado
    var $uf_mapping {
      value = {
        AC: "Acre"
        AL: "Alagoas"
        AP: "Amapá"
        AM: "Amazonas"
        BA: "Bahia"
        CE: "Ceará"
        DF: "Distrito Federal"
        ES: "Espírito Santo"
        GO: "Goiás"
        MA: "Maranhão"
        MT: "Mato Grosso"
        MS: "Mato Grosso do Sul"
        MG: "Minas Gerais"
        PA: "Pará"
        PB: "Paraíba"
        PR: "Paraná"
        PE: "Pernambuco"
        PI: "Piauí"
        RJ: "Rio de Janeiro"
        RN: "Rio Grande do Norte"
        RS: "Rio Grande do Sul"
        RO: "Rondônia"
        RR: "Roraima"
        SC: "Santa Catarina"
        SP: "São Paulo"
        SE: "Sergipe"
        TO: "Tocantins"
      }
    }
  
    // Busca os registros de CEP no banco de dados local
    db.query cep {
      where = $db.cep.cep == $input.cep
      return = {type: "list"}
    } as $cep_records
  
    // Formata o resultado para o padrão solicitado: [ { id, created_at, cep, uf, estado } ]
    array.map ($cep_records) {
      by = {
        id        : $this.id
        created_at: $this.created_at
        cep       : $this.cep
        uf        : $this.estado
        estado    : $uf_mapping|get:$this.estado:$this.estado
      }
    } as $formatted
  }

  response = $formatted
  guid = "hQNocRO3Vp3dPmU_N7o4KSMlcFo"
}