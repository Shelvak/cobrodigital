# coding: utf-8
module CobroDigital
  class Transaccion < CobroDigital::Operador

    CONSULTAR_TRANSACCIONES_WS = 'consultar_transacciones'

    FILTRO_TIPO          = 'tipo'
    FILTRO_NOMBRE        = 'nombre'
    FILTRO_CONCEPTO      = 'concepto'
    FILTRO_NRO_BOLETA    = 'nro_boleta'
    FILTRO_IDENTIFICADOR = 'identificador'

    FILTRO_TIPO_EGRESO            = 'egresos'           # Transacciones de retiro del dinero depositado por los pagadores.
    FILTRO_TIPO_INGRESO           = 'ingresos'          # Todo lo que incremente el saldo de la cuenta CobroDigital. Generalmente son sólo las cobranzas.
    FILTRO_TIPO_TARJETA_CREDITO   = 'tarjeta_credito'   # Solo aquellas cobranzas abonadas con tarjeta de crédito.
    FILTRO_TIPO_DEBITO_AUTOMATICO = 'debito_automatico' # Está relacionado a los débitos realizados por CBU.

    def self.render(desde, hasta, filtros = {})
      {
        :desde   => desde.strftime('%Y%m%d'),
        :hasta   => hasta.strftime('%Y%m%d'),
        :filtros => filtros
      }
    end

    # { 'desde'=>'20160932', 'hasta'=>'20161001' }
    def self.consultar(desde, hasta, filtros = {})
      CobroDigital::Transaccion.new(
        :http_method => CobroDigital::Https::GET,
        :webservice  => CONSULTAR_TRANSACCIONES_WS,
        :render      => render(desde, hasta, filtros)
      )
    end

    def parse_response
      output = response.body[:webservice_cobrodigital_response][:output]
      parsed_response = JSON.parse(output)

      datos = parsed_response['datos'].present? ? (JSON.parse(JSON.parse(output)['datos'].first) rescue []) : []

      { resultado: (parsed_response['ejecucion_correcta'] == '1'), log: parsed_response['log'], datos:  datos }
    end

  end
end
