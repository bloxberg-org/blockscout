defmodule Explorer.Validator.MetadataRetriever do
  @moduledoc """
  Consults the configured smart contracts to fetch the valivators' metadata
  """

  alias Explorer.SmartContract.Reader

  def fetch_data do
    fetch_validators_list()
    |> Enum.map(fn validator ->
      validator
      |> fetch_validator_metadata
      |> translate_metadata
      |> Map.merge(%{address_hash: validator, primary: true})
    end)
  end

  defp fetch_validators_list do
    %{"getValidators" => {:ok, [validators]}} =
      Reader.query_contract(config(:validators_contract_address), contract_abi("validators.json"), %{
        "getValidators" => []
      })
    validators 
  end


  defp fetch_validator_metadata(validator_address) do
    %{"validatorsMetadata" => {:ok, fields}} =
      Reader.query_contract(config(:metadata_contract_address), contract_abi("metadata.json"), %{
        "validatorsMetadata" => [validator_address]
      })

    fields
  end

  defp translate_metadata([
         first_name,
         last_name,
         contactEmail,
         researchInstitute,
         researchField,
         instituteAddress,
         sender
       ]) do
    %{
      name: researchInstitute,
      metadata: %{
        license_id: first_name <> " " <> last_name,
	researchField: researchField,
        address: instituteAddress,
      }
    }
  end

  defp trim_null_bytes(bytes) do
    String.trim_trailing(bytes, <<0>>)
  end

  defp config(key) do
    Application.get_env(:explorer, __MODULE__, [])[key]
  end

  # sobelow_skip ["Traversal"]
  defp contract_abi(file_name) do
    :explorer
    |> Application.app_dir("priv/contracts_abi/poa/#{file_name}")
    |> File.read!()
    |> Jason.decode!()
  end
end
